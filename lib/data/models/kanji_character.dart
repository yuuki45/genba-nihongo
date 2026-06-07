/// 単漢字辞書エントリのデータモデル（漢字辞書パック）
class KanjiCharacter {
  final int? id;
  final String character; // 漢字1文字
  final String onReadings; // 音読み（カタカナ、「・」区切り。なければ空文字）
  final String kunReadings; // 訓読み（ひらがな、「・」区切り。なければ空文字）
  final String meaningId; // 意味（インドネシア語）
  final String? jlptLevel; // 参考JLPTレベル
  final String? packId; // コンテンツパックID（null = 無料）
  final DateTime createdAt;
  final DateTime updatedAt;

  KanjiCharacter({
    this.id,
    required this.character,
    required this.onReadings,
    required this.kunReadings,
    required this.meaningId,
    this.jlptLevel,
    this.packId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからKanjiCharacterオブジェクトを生成
  factory KanjiCharacter.fromJson(Map<String, dynamic> json) {
    return KanjiCharacter(
      id: json['id'] as int?,
      character: json['character'] as String,
      onReadings: json['on_readings'] as String? ?? '',
      kunReadings: json['kun_readings'] as String? ?? '',
      meaningId: json['meaning_id'] as String,
      jlptLevel: json['jlpt_level'] as String?,
      packId: json['pack_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// データベースMap形式からKanjiCharacterオブジェクトを生成
  factory KanjiCharacter.fromMap(Map<String, dynamic> map) {
    return KanjiCharacter(
      id: map['id'] as int?,
      character: map['character'] as String,
      onReadings: map['on_readings'] as String? ?? '',
      kunReadings: map['kun_readings'] as String? ?? '',
      meaningId: map['meaning_id'] as String,
      jlptLevel: map['jlpt_level'] as String?,
      packId: map['pack_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// KanjiCharacterオブジェクトをデータベースMap形式に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': character,
      'on_readings': onReadings,
      'kun_readings': kunReadings,
      'meaning_id': meaningId,
      'jlpt_level': jlptLevel,
      'pack_id': packId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
