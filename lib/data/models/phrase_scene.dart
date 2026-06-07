/// フレーズのシーン（職種・生活場面）定義
///
/// フレーズ一覧をシーン単位で切り分けるためのグルーピング。
/// カテゴリ（categoriesテーブル）を束ねる上位概念で、固定のため定数として保持する。
/// 新しい職種パックを追加する際は、カテゴリ追加 + ここに1エントリ追加する。
class PhraseScene {
  final String key;
  final String nameJa;
  final String nameId;
  final String descriptionJa;
  final String descriptionId;
  final String icon;

  /// このシーンに含まれるカテゴリID
  final List<int> categoryIds;

  const PhraseScene({
    required this.key,
    required this.nameJa,
    required this.nameId,
    required this.descriptionJa,
    required this.descriptionId,
    required this.icon,
    required this.categoryIds,
  });

  /// すべてのシーン（表示順）
  static const List<PhraseScene> all = [
    PhraseScene(
      key: 'factory',
      nameJa: '工場・現場',
      nameId: 'Pabrik & Lapangan',
      descriptionJa: '安全・作業指示・緊急時のフレーズ',
      descriptionId: 'Frasa keselamatan, instruksi kerja, dan darurat',
      icon: '🏭',
      categoryIds: [2, 3, 5],
    ),
    PhraseScene(
      key: 'daily',
      nameJa: '日常・あいさつ',
      nameId: 'Sehari-hari & Salam',
      descriptionJa: 'あいさつ・日常会話のフレーズ',
      descriptionId: 'Frasa salam dan percakapan sehari-hari',
      icon: '💬',
      categoryIds: [1, 4],
    ),
    PhraseScene(
      key: 'kaigo',
      nameJa: '介護',
      nameId: 'Perawatan',
      descriptionJa: '声かけ・介助・申し送りのフレーズ',
      descriptionId: 'Frasa sapaan, bantuan perawatan, dan serah terima',
      icon: '🤲',
      categoryIds: [6],
    ),
  ];

  /// キーからシーンを取得
  static PhraseScene? fromKey(String key) {
    for (final scene in all) {
      if (scene.key == key) return scene;
    }
    return null;
  }
}
