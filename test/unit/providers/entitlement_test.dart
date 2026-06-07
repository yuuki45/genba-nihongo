import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/iap/product_catalog.dart';
import 'package:nihongo/data/iap/purchase_service.dart';
import 'package:nihongo/data/repositories/purchase_repository.dart';
import 'package:nihongo/presentation/providers/purchase_provider.dart';

/// テスト用のフェイクPurchaseService（RevenueCatの代わり）
class FakePurchaseService implements PurchaseService {
  bool configured = true;
  void Function(Map<String, String>)? entitlementCallback;

  /// buy/restoreの結果として返すEntitlement（packId → productId）
  Map<String, String> nextEntitlements = {};

  /// buy/restoreで投げる例外（nullなら成功）
  Object? nextError;

  @override
  Future<bool> initialize() async => configured;

  @override
  void setOnEntitlementsChanged(
      void Function(Map<String, String>)? callback) {
    entitlementCallback = callback;
  }

  @override
  Future<List<PackProduct>> queryProducts(Set<String> productIds) async => [];

  @override
  Future<Map<String, String>> buy(String productId) async {
    if (nextError != null) throw nextError!;
    return nextEntitlements;
  }

  @override
  Future<Map<String, String>> restorePurchases() async {
    if (nextError != null) throw nextError!;
    return nextEntitlements;
  }
}

/// テスト用のフェイクPurchaseRepository（メモリ上で解錠管理）
class FakePurchaseRepository implements PurchaseRepository {
  final Map<String, String> unlocked = {}; // productId -> packId
  final List<String> sources = [];

  @override
  Future<Set<String>> getUnlockedPackIds() async => unlocked.values.toSet();

  @override
  Future<void> unlockPack(
    String productId,
    String packId, {
    required bool restored,
  }) async {
    unlocked[productId] = packId;
    sources.add(restored ? 'restore' : 'purchase');
  }

  @override
  Future<bool> isPackUnlocked(String packId) async =>
      unlocked.containsValue(packId);
}

void main() {
  late FakePurchaseService service;
  late FakePurchaseRepository repository;
  late EntitlementNotifier notifier;

  final productId = ProductCatalog.jlptPack.productId;
  final packId = ProductCatalog.jlptPack.packId;

  Future<void> pump() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() async {
    service = FakePurchaseService();
    repository = FakePurchaseRepository();
    notifier = EntitlementNotifier(service, repository);
    await pump(); // _initialize（DBロード・購読開始）の完了を待つ
  });

  tearDown(() {
    notifier.dispose();
  });

  group('EntitlementNotifier（RevenueCat連携）テスト', () {
    test('初期状態は未解錠・idleで、Entitlement購読が開始される', () {
      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(service.entitlementCallback, isNotNull);
    });

    test('RevenueCat未設定でもローカルDBの解錠状態で動作する', () async {
      final offlineService = FakePurchaseService()..configured = false;
      final offlineRepo = FakePurchaseRepository();
      await offlineRepo.unlockPack(productId, packId, restored: false);

      final offlineNotifier = EntitlementNotifier(offlineService, offlineRepo);
      await pump();

      expect(offlineNotifier.state.unlockedPackIds, contains(packId));
      // 未設定なので購読は開始されない
      expect(offlineService.entitlementCallback, isNull);
      offlineNotifier.dispose();
    });

    test('購入成功でパックが解錠される', () async {
      service.nextEntitlements = {packId: productId};
      await notifier.buy(productId);

      expect(notifier.state.unlockedPackIds, contains(packId));
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(repository.sources, ['purchase']);
    });

    test('購入キャンセルは解錠せず静かにidleへ戻る', () async {
      service.nextError = PurchaseCancelledException();
      await notifier.buy(productId);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(notifier.state.errorMessage, isNull);
    });

    test('承認待ちはpending状態になり解錠しない', () async {
      service.nextError = PurchasePendingException();
      await notifier.buy(productId);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.pending);
    });

    test('購入エラーはerror状態になる', () async {
      service.nextError = Exception('store error');
      await notifier.buy(productId);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.error);
      expect(notifier.state.errorMessage, contains('store error'));
    });

    test('復元でパックが解錠される（source=restore）', () async {
      service.nextEntitlements = {packId: productId};
      await notifier.restore();

      expect(notifier.state.unlockedPackIds, contains(packId));
      expect(repository.sources, ['restore']);
    });

    test('Entitlement更新リスナー経由でも解錠される（アプリ外購入の回収）', () async {
      service.entitlementCallback!({packId: productId});
      await pump();

      expect(notifier.state.unlockedPackIds, contains(packId));
    });

    test('カタログにないEntitlementは無視される', () async {
      service.nextEntitlements = {'unknown_pack': 'com.unknown.product'};
      await notifier.buy(productId);

      expect(notifier.state.unlockedPackIds, isEmpty);
    });

    test('複数パックのEntitlementをまとめて解錠できる', () async {
      service.nextEntitlements = {
        ProductCatalog.jlptPack.packId: ProductCatalog.jlptPack.productId,
        ProductCatalog.kaigoPack.packId: ProductCatalog.kaigoPack.productId,
      };
      await notifier.restore();

      expect(notifier.state.unlockedPackIds,
          containsAll([ProductCatalog.jlptPack.packId, ProductCatalog.kaigoPack.packId]));
    });

    test('clearErrorでidleに戻る', () async {
      service.nextError = Exception('x');
      await notifier.buy(productId);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.error);

      notifier.clearError();
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(notifier.state.errorMessage, isNull);
    });
  });

  group('解錠フィルタ純粋関数テスト', () {
    test('packIdがnull（無料）は常に利用可能', () {
      expect(isContentUnlocked(null, {}), isTrue);
      expect(isContentUnlocked(null, {'jlpt_n3n2'}), isTrue);
    });

    test('未解錠パックは利用不可、解錠済みは利用可能', () {
      expect(isContentUnlocked('jlpt_n3n2', {}), isFalse);
      expect(isContentUnlocked('jlpt_n3n2', {'jlpt_n3n2'}), isTrue);
      expect(isContentUnlocked('kaigo', {'jlpt_n3n2'}), isFalse);
    });

    test('filterUnlockedContentは無料+解錠済みだけを通す', () {
      final items = [
        (name: 'free', packId: null),
        (name: 'jlpt', packId: 'jlpt_n3n2'),
        (name: 'kaigo', packId: 'kaigo'),
      ];

      final result = filterUnlockedContent(
        items,
        (item) => item.packId,
        {'jlpt_n3n2'},
      );

      expect(result.map((i) => i.name), ['free', 'jlpt']);
    });
  });
}
