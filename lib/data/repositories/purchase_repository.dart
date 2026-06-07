import '../datasources/local/database_helper.dart';

/// 購入リポジトリ
///
/// コンテンツパックの解錠状態をローカルDBで管理する。
/// 解錠判定はこのリポジトリのみを参照するため、オフラインでも
/// 購入済みコンテンツが利用できる（サーバーレス設計）。
class PurchaseRepository {
  final DatabaseHelper _dbHelper;

  PurchaseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// 解錠済みのパックID集合を取得
  Future<Set<String>> getUnlockedPackIds() async {
    final purchases = await _dbHelper.getAllPurchases();
    return purchases.map((p) => p['pack_id'] as String).toSet();
  }

  /// パックを解錠（購入・復元時に呼ぶ。同一商品は置き換え＝冪等）
  Future<void> unlockPack(
    String productId,
    String packId, {
    required bool restored,
  }) async {
    await _dbHelper.upsertPurchase({
      'product_id': productId,
      'pack_id': packId,
      'purchased_at': DateTime.now().toIso8601String(),
      'source': restored ? 'restore' : 'purchase',
    });
  }

  /// パックが解錠済みか確認
  Future<bool> isPackUnlocked(String packId) async {
    final unlockedPackIds = await getUnlockedPackIds();
    return unlockedPackIds.contains(packId);
  }
}
