import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/iap/product_catalog.dart';
import '../../data/iap/purchase_service.dart';
import '../../data/repositories/purchase_repository.dart';

/// PurchaseServiceのProvider
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

/// PurchaseRepositoryのProvider
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});

/// ストアから商品情報を取得するProvider
///
/// RevenueCat未設定・オフライン等の場合は空リストを返す。
/// 解錠判定には影響しない（解錠はローカルDBのみ参照）。
final productsProvider = FutureProvider<List<PackProduct>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  return await service.queryProducts(ProductCatalog.allProductIds);
});

/// 購入フローの進行状態（UI表示用）
enum PurchaseFlowStatus {
  idle, // 通常
  purchasing, // 購入処理中
  pending, // ストア側の承認待ち（ペアレンタルコントロール等）
  error, // エラー発生
}

/// 解錠状態 + 購入フロー状態
class EntitlementState {
  /// 解錠済みのパックID集合
  final Set<String> unlockedPackIds;

  /// 購入フローの進行状態
  final PurchaseFlowStatus flowStatus;

  /// エラーメッセージ（flowStatus == error のとき）
  final String? errorMessage;

  const EntitlementState({
    this.unlockedPackIds = const {},
    this.flowStatus = PurchaseFlowStatus.idle,
    this.errorMessage,
  });

  EntitlementState copyWith({
    Set<String>? unlockedPackIds,
    PurchaseFlowStatus? flowStatus,
    String? errorMessage,
  }) {
    return EntitlementState(
      unlockedPackIds: unlockedPackIds ?? this.unlockedPackIds,
      flowStatus: flowStatus ?? this.flowStatus,
      // エラーメッセージはerror状態のときだけ保持する
      errorMessage: (flowStatus ?? this.flowStatus) == PurchaseFlowStatus.error
          ? (errorMessage ?? this.errorMessage)
          : null,
    );
  }

  /// パックが解錠済みか
  bool isUnlocked(String packId) => unlockedPackIds.contains(packId);
}

/// 解錠状態の管理クラス（RevenueCat連携）
///
/// - 起動時にローカルDBから解錠状態をロード（オフラインでも即値が出る）
/// - RevenueCatのEntitlement更新を購読し、ローカルDBへ書き込んで解錠
///   （アプリ外での購入完了・ファミリー共有もここで回収できる）
/// - RevenueCatのEntitlement IDはpackIdと一致させる運用
class EntitlementNotifier extends StateNotifier<EntitlementState> {
  final PurchaseService _service;
  final PurchaseRepository _repository;

  EntitlementNotifier(this._service, this._repository)
      : super(const EntitlementState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // ローカルDBから解錠状態をロード
    final unlocked = await _repository.getUnlockedPackIds();
    if (mounted) {
      state = state.copyWith(unlockedPackIds: unlocked);
    }

    // RevenueCatを初期化（未設定・失敗時はローカルのみで動作継続）
    final configured = await _service.initialize();
    if (!configured) return;

    // Entitlement更新の購読を開始
    _service.setOnEntitlementsChanged((activeEntitlements) {
      _syncEntitlements(activeEntitlements, restored: false);
    });
  }

  /// 有効なEntitlement（packId → productId）をローカルDBへ反映する
  ///
  /// カタログにないEntitlementは無視する。一度解錠したパックは
  /// RC側で無効になってもローカルでは取り消さない（オフライン体験を優先）。
  Future<void> _syncEntitlements(
    Map<String, String> activeEntitlements, {
    required bool restored,
  }) async {
    for (final entry in activeEntitlements.entries) {
      final packId = entry.key;
      final productId = entry.value;
      if (ProductCatalog.fromPackId(packId) == null) continue;
      await _repository.unlockPack(productId, packId, restored: restored);
    }

    final unlocked = await _repository.getUnlockedPackIds();
    if (mounted) {
      state = state.copyWith(
        unlockedPackIds: unlocked,
        flowStatus: PurchaseFlowStatus.idle,
      );
    }
  }

  /// 購入を開始する
  Future<void> buy(String productId) async {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.purchasing);
    try {
      final entitlements = await _service.buy(productId);
      await _syncEntitlements(entitlements, restored: false);
    } on PurchaseCancelledException {
      // ユーザーによるキャンセル。エラー表示はせず静かに戻す
      if (mounted) {
        state = state.copyWith(flowStatus: PurchaseFlowStatus.idle);
      }
    } on PurchasePendingException {
      // 承認されるとEntitlement更新リスナー経由で自動解錠される
      if (mounted) {
        state = state.copyWith(flowStatus: PurchaseFlowStatus.pending);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          flowStatus: PurchaseFlowStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// 過去の購入を復元する（App Store審査の必須要件）
  Future<void> restore() async {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.purchasing);
    try {
      final entitlements = await _service.restorePurchases();
      await _syncEntitlements(entitlements, restored: true);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          flowStatus: PurchaseFlowStatus.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  /// エラー表示をクリアする
  void clearError() {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.idle);
  }

  @override
  void dispose() {
    _service.setOnEntitlementsChanged(null);
    super.dispose();
  }
}

/// 解錠状態Provider
///
/// アプリ起動直後にwatch/readして購読を開始すること
/// （アプリ外での購入完了の回収のため）。
final entitlementProvider =
    StateNotifierProvider<EntitlementNotifier, EntitlementState>((ref) {
  return EntitlementNotifier(
    ref.watch(purchaseServiceProvider),
    ref.watch(purchaseRepositoryProvider),
  );
});

/// コンテンツが利用可能か判定する純粋関数
///
/// packIdがnull（無料）または解錠済みならtrue。テスト容易性のため分離。
bool isContentUnlocked(String? packId, Set<String> unlockedPackIds) {
  return packId == null || unlockedPackIds.contains(packId);
}

/// リストから利用可能なコンテンツだけを抽出する純粋関数
List<T> filterUnlockedContent<T>(
  List<T> items,
  String? Function(T item) packIdOf,
  Set<String> unlockedPackIds,
) {
  return items
      .where((item) => isContentUnlocked(packIdOf(item), unlockedPackIds))
      .toList();
}
