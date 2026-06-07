/// コンテンツパックの商品カタログ
///
/// App Store Connect / Google Play Console に登録する商品ID（productId）と、
/// アプリ内のコンテンツ解錠キー（packId）の対応を一元管理する。
/// 価格・タイトル・説明文はストア側が真実（ProductDetailsを表示に使う）。
class ContentPack {
  /// ストアの商品ID（App Store Connectに登録するID）
  final String productId;

  /// アプリ内の解錠キー（phrases/quizzesのpack_id列と対応）
  final String packId;

  /// ストア接続できない場合のフォールバック表示名（日本語）
  final String fallbackNameJa;

  /// ストア接続できない場合のフォールバック表示名（インドネシア語）
  final String fallbackNameId;

  /// パックのアイコン（絵文字）
  final String icon;

  const ContentPack({
    required this.productId,
    required this.packId,
    required this.fallbackNameJa,
    required this.fallbackNameId,
    required this.icon,
  });
}

/// 商品カタログ
class ProductCatalog {
  ProductCatalog._();

  /// JLPT N3/N2対策パック
  static const ContentPack jlptPack = ContentPack(
    productId: 'com.genba.nihongo.pack.jlpt_n3n2',
    packId: 'jlpt_n3n2',
    fallbackNameJa: 'JLPT N3/N2対策パック',
    fallbackNameId: 'Paket Persiapan JLPT N3/N2',
    icon: '📚',
  );

  /// 販売中の全パック（フェーズ1以降で追加していく）
  static const List<ContentPack> all = [
    jlptPack,
  ];

  /// 全商品IDの集合（ストアへの問い合わせに使用）
  static Set<String> get allProductIds =>
      all.map((pack) => pack.productId).toSet();

  /// 商品IDからパックを取得
  static ContentPack? fromProductId(String productId) {
    for (final pack in all) {
      if (pack.productId == productId) return pack;
    }
    return null;
  }

  /// パックIDからパックを取得
  static ContentPack? fromPackId(String packId) {
    for (final pack in all) {
      if (pack.packId == packId) return pack;
    }
    return null;
  }
}
