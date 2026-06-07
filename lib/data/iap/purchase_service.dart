import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_config.dart';

/// ストア商品の表示用DTO
///
/// RevenueCat（purchases_flutter）の型をUI層・テストに漏らさないための薄い入れ物。
class PackProduct {
  final String productId;
  final String title;
  final String description;
  final String priceString;

  const PackProduct({
    required this.productId,
    required this.title,
    required this.description,
    required this.priceString,
  });
}

/// ユーザーが購入をキャンセルした
class PurchaseCancelledException implements Exception {}

/// ストア側の承認待ち（ペアレンタルコントロール等）
class PurchasePendingException implements Exception {}

/// アプリ内課金サービス（RevenueCatラッパー）
///
/// - RevenueCatのEntitlement IDはアプリのpackId（jlpt_n3n2等）と一致させる運用
/// - 解錠状態の永続化はPurchaseRepositoryが担う（RCのキャッシュと二重化し、
///   完全オフラインでも購入済みコンテンツが使えるアプリの設計を維持する）
class PurchaseService {
  Future<bool>? _initialization;
  CustomerInfoUpdateListener? _listener;

  /// 商品IDからStoreProductへのキャッシュ（購入時に使用）
  final Map<String, StoreProduct> _productCache = {};

  /// RevenueCatを初期化する（多重呼び出しは1回にまとめられる）
  ///
  /// APIキー未設定や接続失敗時はfalseを返し、アプリは
  /// ローカルDBの解錠状態のみで動作を続ける。
  Future<bool> initialize() {
    return _initialization ??= _configure();
  }

  Future<bool> _configure() async {
    if (!isRevenueCatConfigured) return false;
    try {
      await Purchases.configure(PurchasesConfiguration(revenueCatAppleApiKey));
      return true;
    } catch (_) {
      _initialization = null; // 次回リトライできるようにする
      return false;
    }
  }

  /// 有効なEntitlementの更新通知を設定する（nullで解除）
  ///
  /// コールバックには {packId: productId} のマップが渡される。
  /// アプリ外での購入完了・ファミリー共有などもここに流れてくる。
  void setOnEntitlementsChanged(
    void Function(Map<String, String> activeEntitlements)? callback,
  ) {
    if (_listener != null) {
      Purchases.removeCustomerInfoUpdateListener(_listener!);
      _listener = null;
    }
    if (callback != null) {
      _listener = (customerInfo) => callback(_activeEntitlements(customerInfo));
      Purchases.addCustomerInfoUpdateListener(_listener!);
    }
  }

  /// CustomerInfoから有効なEntitlement（packId → productId）を抽出
  static Map<String, String> _activeEntitlements(CustomerInfo customerInfo) {
    return {
      for (final entitlement in customerInfo.entitlements.active.values)
        entitlement.identifier: entitlement.productIdentifier,
    };
  }

  /// ストアから商品情報を取得
  Future<List<PackProduct>> queryProducts(Set<String> productIds) async {
    if (!await initialize()) return [];

    final products = await Purchases.getProducts(
      productIds.toList(),
      productCategory: ProductCategory.nonSubscription,
    );
    for (final product in products) {
      _productCache[product.identifier] = product;
    }
    return products
        .map((product) => PackProduct(
              productId: product.identifier,
              title: product.title,
              description: product.description,
              priceString: product.priceString,
            ))
        .toList();
  }

  /// 買い切り商品を購入し、購入後の有効Entitlement（packId → productId）を返す
  ///
  /// キャンセル時は[PurchaseCancelledException]、
  /// 承認待ち時は[PurchasePendingException]を投げる。
  Future<Map<String, String>> buy(String productId) async {
    var product = _productCache[productId];
    if (product == null) {
      final fetched = await Purchases.getProducts(
        [productId],
        productCategory: ProductCategory.nonSubscription,
      );
      if (fetched.isEmpty) {
        throw Exception('商品が見つかりません: $productId');
      }
      product = fetched.first;
      _productCache[productId] = product;
    }

    try {
      final customerInfo = await Purchases.purchaseStoreProduct(product);
      return _activeEntitlements(customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw PurchaseCancelledException();
      }
      if (errorCode == PurchasesErrorCode.paymentPendingError) {
        throw PurchasePendingException();
      }
      rethrow;
    }
  }

  /// 過去の購入を復元し、有効Entitlement（packId → productId）を返す
  Future<Map<String, String>> restorePurchases() async {
    final customerInfo = await Purchases.restorePurchases();
    return _activeEntitlements(customerInfo);
  }
}
