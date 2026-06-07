/// 漢字語（現場の掲示・標識の表示語）データモデル
class KanjiWord {
  final int? id;
  final String word; // 表示語（例: 立入禁止）
  final String reading; // ひらがな読み
  final String romaji;
  final String indonesian;
  final String category; // カテゴリキー（safety, equipment, place, work, attendance）
  final String? descriptionJa; // どこで見るかの説明（日本語）
  final String? descriptionId; // どこで見るかの説明（インドネシア語）
  final int importance;
  final String jlptLevel; // 参考JLPTレベル
  final DateTime createdAt;
  final DateTime updatedAt;

  KanjiWord({
    this.id,
    required this.word,
    required this.reading,
    required this.romaji,
    required this.indonesian,
    required this.category,
    this.descriptionJa,
    this.descriptionId,
    this.importance = 1,
    this.jlptLevel = 'N4',
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからKanjiWordオブジェクトを生成
  factory KanjiWord.fromJson(Map<String, dynamic> json) {
    return KanjiWord(
      id: json['id'] as int?,
      word: json['word'] as String,
      reading: json['reading'] as String,
      romaji: json['romaji'] as String,
      indonesian: json['indonesian'] as String,
      category: json['category'] as String,
      descriptionJa: json['description_ja'] as String?,
      descriptionId: json['description_id'] as String?,
      importance: json['importance'] as int? ?? 1,
      jlptLevel: json['jlpt_level'] as String? ?? 'N4',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// KanjiWordオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'reading': reading,
      'romaji': romaji,
      'indonesian': indonesian,
      'category': category,
      'description_ja': descriptionJa,
      'description_id': descriptionId,
      'importance': importance,
      'jlpt_level': jlptLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// データベースMap形式からKanjiWordオブジェクトを生成
  factory KanjiWord.fromMap(Map<String, dynamic> map) {
    return KanjiWord(
      id: map['id'] as int?,
      word: map['word'] as String,
      reading: map['reading'] as String,
      romaji: map['romaji'] as String,
      indonesian: map['indonesian'] as String,
      category: map['category'] as String,
      descriptionJa: map['description_ja'] as String?,
      descriptionId: map['description_id'] as String?,
      importance: map['importance'] as int? ?? 1,
      jlptLevel: map['jlpt_level'] as String? ?? 'N4',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// KanjiWordオブジェクトをデータベースMap形式に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'reading': reading,
      'romaji': romaji,
      'indonesian': indonesian,
      'category': category,
      'description_ja': descriptionJa,
      'description_id': descriptionId,
      'importance': importance,
      'jlpt_level': jlptLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// イミュータブルなコピーを作成
  KanjiWord copyWith({
    int? id,
    String? word,
    String? reading,
    String? romaji,
    String? indonesian,
    String? category,
    String? descriptionJa,
    String? descriptionId,
    int? importance,
    String? jlptLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KanjiWord(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      romaji: romaji ?? this.romaji,
      indonesian: indonesian ?? this.indonesian,
      category: category ?? this.category,
      descriptionJa: descriptionJa ?? this.descriptionJa,
      descriptionId: descriptionId ?? this.descriptionId,
      importance: importance ?? this.importance,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KanjiWord(id: $id, word: $word, reading: $reading, indonesian: $indonesian)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KanjiWord &&
        other.id == id &&
        other.word == word &&
        other.reading == reading &&
        other.romaji == romaji &&
        other.indonesian == indonesian &&
        other.category == category &&
        other.descriptionJa == descriptionJa &&
        other.descriptionId == descriptionId &&
        other.importance == importance &&
        other.jlptLevel == jlptLevel &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      word,
      reading,
      romaji,
      indonesian,
      category,
      descriptionJa,
      descriptionId,
      importance,
      jlptLevel,
      createdAt,
      updatedAt,
    );
  }
}

/// 漢字語カテゴリの定義
///
/// カテゴリは固定の5種類のため、DBではなく定数として保持する。
class KanjiCategory {
  final String key;
  final String nameJa;
  final String nameId;
  final String icon;

  const KanjiCategory({
    required this.key,
    required this.nameJa,
    required this.nameId,
    required this.icon,
  });

  /// すべてのカテゴリ（表示順）
  static const List<KanjiCategory> all = [
    KanjiCategory(key: 'safety', nameJa: '安全標識', nameId: 'Rambu Keselamatan', icon: '⚠️'),
    KanjiCategory(key: 'equipment', nameJa: '設備・操作', nameId: 'Peralatan & Operasi', icon: '🔧'),
    KanjiCategory(key: 'place', nameJa: '場所・案内', nameId: 'Tempat & Petunjuk', icon: '📍'),
    KanjiCategory(key: 'work', nameJa: '品質・作業', nameId: 'Kualitas & Pekerjaan', icon: '📦'),
    KanjiCategory(key: 'attendance', nameJa: '勤怠・書類', nameId: 'Kehadiran & Dokumen', icon: '📋'),
  ];

  /// キーからカテゴリを取得
  static KanjiCategory? fromKey(String key) {
    for (final category in all) {
      if (category.key == key) return category;
    }
    return null;
  }
}
