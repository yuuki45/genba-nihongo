import 'package:in_app_purchase/in_app_purchase.dart';

/// アプリ内課金サービス
///
/// in_app_purchase（ストアSDK）の薄いラッパー。
/// 永続化やビジネスロジックは持たず、テスト時はこのクラスをモックする。
class PurchaseService {
  final InAppPurchase _inAppPurchase;

  PurchaseService({InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  /// ストアが利用可能か
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  /// 購入状態の更新ストリーム
  ///
  /// 購入完了・復元・キャンセル・エラー・pendingがすべてここに流れる。
  /// アプリ起動直後に購読を開始すること（中断したトランザクションの回収のため）。
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  /// ストアから商品情報を取得
  Future<List<ProductDetails>> queryProducts(Set<String> productIds) async {
    final response = await _inAppPurchase.queryProductDetails(productIds);
    return response.productDetails;
  }

  /// 買い切り商品（non-consumable）の購入を開始
  ///
  /// 結果は purchaseStream に流れてくる。
  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 過去の購入を復元（App Store審査の必須要件）
  ///
  /// 復元結果は purchaseStream に PurchaseStatus.restored として流れてくる。
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  /// トランザクションを完了する
  ///
  /// purchased / restored / error を受け取ったら必ず呼ぶこと。
  /// 呼ばないとiOSでトランザクションがキューに残り続ける。
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }
}
