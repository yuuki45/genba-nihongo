import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
/// ストア未接続（オフライン等）の場合は空リストを返す。
/// 解錠判定には影響しない（解錠はローカルDBのみ参照）。
final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  if (!await service.isAvailable()) return [];
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

/// 解錠状態の管理クラス
///
/// - 起動時にローカルDBから解錠状態をロード（オフラインでも即値が出る）
/// - purchaseStreamを購読し、購入・復元をDBへ書き込んで解錠
/// - 起動直後に購読を開始することで、中断したトランザクションも回収できる
class EntitlementNotifier extends StateNotifier<EntitlementState> {
  final PurchaseService _service;
  final PurchaseRepository _repository;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

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

    // 購入ストリームの購読を開始
    _subscription = _service.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error) {
        if (mounted) {
          state = state.copyWith(
            flowStatus: PurchaseFlowStatus.error,
            errorMessage: error.toString(),
          );
        }
      },
    );
  }

  /// purchaseStreamから届く購入状態の更新を処理する
  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _unlock(purchase);
          await _service.completePurchase(purchase);
          break;

        case PurchaseStatus.pending:
          // ストア側の承認待ち。解錠せず、完了が流れてくるのを待つ
          if (mounted) {
            state = state.copyWith(flowStatus: PurchaseFlowStatus.pending);
          }
          break;

        case PurchaseStatus.canceled:
          // ユーザーによるキャンセル。エラー表示はせず静かに戻す
          if (mounted) {
            state = state.copyWith(flowStatus: PurchaseFlowStatus.idle);
          }
          break;

        case PurchaseStatus.error:
          if (mounted) {
            state = state.copyWith(
              flowStatus: PurchaseFlowStatus.error,
              errorMessage: purchase.error?.message,
            );
          }
          // トランザクションを解放（呼ばないとキューに残り続ける）
          await _service.completePurchase(purchase);
          break;
      }
    }
  }

  /// パックを解錠してDBに永続化する
  Future<void> _unlock(PurchaseDetails purchase) async {
    final pack = ProductCatalog.fromProductId(purchase.productID);
    if (pack == null) return; // カタログにない商品は無視

    await _repository.unlockPack(
      pack.productId,
      pack.packId,
      restored: purchase.status == PurchaseStatus.restored,
    );

    final unlocked = await _repository.getUnlockedPackIds();
    if (mounted) {
      state = state.copyWith(
        unlockedPackIds: unlocked,
        flowStatus: PurchaseFlowStatus.idle,
      );
    }
  }

  /// 購入を開始する（結果はpurchaseStream経由で反映される）
  Future<void> buy(ProductDetails product) async {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.purchasing);
    try {
      await _service.buy(product);
    } catch (e) {
      state = state.copyWith(
        flowStatus: PurchaseFlowStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 過去の購入を復元する（App Store審査の必須要件）
  Future<void> restore() async {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.purchasing);
    try {
      await _service.restorePurchases();
      // 復元対象はpurchaseStreamにrestoredとして流れてくる。
      // 対象が0件の場合は何も流れないため、ここでidleに戻しておく
      if (mounted && state.flowStatus == PurchaseFlowStatus.purchasing) {
        state = state.copyWith(flowStatus: PurchaseFlowStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(
        flowStatus: PurchaseFlowStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// エラー表示をクリアする
  void clearError() {
    state = state.copyWith(flowStatus: PurchaseFlowStatus.idle);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// 解錠状態Provider
///
/// アプリ起動直後にwatch/readして購読を開始すること
/// （中断したトランザクションの回収のため）。
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
