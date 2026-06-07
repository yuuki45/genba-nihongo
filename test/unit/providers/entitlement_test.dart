import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nihongo/data/iap/product_catalog.dart';
import 'package:nihongo/data/iap/purchase_service.dart';
import 'package:nihongo/data/repositories/purchase_repository.dart';
import 'package:nihongo/presentation/providers/purchase_provider.dart';

/// テスト用のフェイクPurchaseService（ストリームを手動で流せる）
class FakePurchaseService implements PurchaseService {
  final StreamController<List<PurchaseDetails>> controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  final List<PurchaseDetails> completedPurchases = [];
  bool storeAvailable = true;

  @override
  Future<bool> isAvailable() async => storeAvailable;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<List<ProductDetails>> queryProducts(Set<String> productIds) async =>
      [];

  @override
  Future<void> buy(ProductDetails product) async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase);
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

/// テスト用のPurchaseDetailsを生成
PurchaseDetails makePurchase(
  String productId,
  PurchaseStatus status, {
  bool pendingComplete = true,
}) {
  final purchase = PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
  purchase.pendingCompletePurchase = pendingComplete;
  return purchase;
}

void main() {
  late FakePurchaseService service;
  late FakePurchaseRepository repository;
  late EntitlementNotifier notifier;

  final productId = ProductCatalog.jlptPack.productId;
  final packId = ProductCatalog.jlptPack.packId;

  setUp(() async {
    service = FakePurchaseService();
    repository = FakePurchaseRepository();
    notifier = EntitlementNotifier(service, repository);
    // _initialize内の非同期処理（DBロード・購読開始）の完了を待つ
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() {
    notifier.dispose();
    service.controller.close();
  });

  /// ストリームへイベントを流して処理完了を待つ
  Future<void> emit(List<PurchaseDetails> purchases) async {
    service.controller.add(purchases);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  group('EntitlementNotifier テスト', () {
    test('初期状態は未解錠・idle', () {
      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
    });

    test('purchasedイベントでパックが解錠され、completePurchaseが呼ばれる', () async {
      await emit([makePurchase(productId, PurchaseStatus.purchased)]);

      expect(notifier.state.unlockedPackIds, contains(packId));
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(service.completedPurchases, hasLength(1));
      expect(repository.sources, ['purchase']);
    });

    test('restoredイベントでもパックが解錠される（source=restore）', () async {
      await emit([makePurchase(productId, PurchaseStatus.restored)]);

      expect(notifier.state.unlockedPackIds, contains(packId));
      expect(repository.sources, ['restore']);
    });

    test('canceledイベントは解錠せず静かにidleへ戻る', () async {
      await emit([
        makePurchase(productId, PurchaseStatus.canceled, pendingComplete: false),
      ]);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.idle);
      expect(notifier.state.errorMessage, isNull);
    });

    test('pendingイベントは解錠せずpending状態になる', () async {
      await emit([
        makePurchase(productId, PurchaseStatus.pending, pendingComplete: false),
      ]);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.pending);
    });

    test('errorイベントはerror状態になり、トランザクションは解放される', () async {
      await emit([makePurchase(productId, PurchaseStatus.error)]);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(notifier.state.flowStatus, PurchaseFlowStatus.error);
      expect(service.completedPurchases, hasLength(1));
    });

    test('カタログにない商品IDは解錠されないがトランザクションは解放される', () async {
      await emit([makePurchase('com.unknown.product', PurchaseStatus.purchased)]);

      expect(notifier.state.unlockedPackIds, isEmpty);
      expect(service.completedPurchases, hasLength(1));
    });

    test('同一商品の二重イベントでも解錠は冪等', () async {
      await emit([makePurchase(productId, PurchaseStatus.purchased)]);
      await emit([makePurchase(productId, PurchaseStatus.restored)]);

      expect(notifier.state.unlockedPackIds, hasLength(1));
    });

    test('clearErrorでidleに戻る', () async {
      await emit([makePurchase(productId, PurchaseStatus.error)]);
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
