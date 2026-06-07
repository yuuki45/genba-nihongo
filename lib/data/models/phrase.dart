/// フレーズデータモデル
class Phrase {
  final int? id;
  final String japanese;
  final String romaji;
  final String indonesian;
  final int categoryId;
  final String? audioPath;
  final int importance;
  final String? usageContext;
  final String jlptLevel; // N5, N4, N3
  final DateTime createdAt;
  final DateTime updatedAt;

  Phrase({
    this.id,
    required this.japanese,
    required this.romaji,
    required this.indonesian,
    required this.categoryId,
    this.audioPath,
    this.importance = 1,
    this.usageContext,
    this.jlptLevel = 'N5',
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからPhraseオブジェクトを生成
  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      id: json['id'] as int?,
      japanese: json['japanese'] as String,
      romaji: json['romaji'] as String,
      indonesian: json['indonesian'] as String,
      categoryId: json['category_id'] as int,
      audioPath: json['audio_path'] as String?,
      importance: json['importance'] as int? ?? 1,
      usageContext: json['usage_context'] as String?,
      jlptLevel: json['jlpt_level'] as String? ?? 'N5',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// PhraseオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'japanese': japanese,
      'romaji': romaji,
      'indonesian': indonesian,
      'category_id': categoryId,
      'audio_path': audioPath,
      'importance': importance,
      'usage_context': usageContext,
      'jlpt_level': jlptLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// データベースMap形式からPhraseオブジェクトを生成
  factory Phrase.fromMap(Map<String, dynamic> map) {
    return Phrase(
      id: map['id'] as int?,
      japanese: map['japanese'] as String,
      romaji: map['romaji'] as String,
      indonesian: map['indonesian'] as String,
      categoryId: map['category_id'] as int,
      audioPath: map['audio_path'] as String?,
      importance: map['importance'] as int? ?? 1,
      usageContext: map['usage_context'] as String?,
      jlptLevel: map['jlpt_level'] as String? ?? 'N5',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// PhraseオブジェクトをデータベースMap形式に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'japanese': japanese,
      'romaji': romaji,
      'indonesian': indonesian,
      'category_id': categoryId,
      'audio_path': audioPath,
      'importance': importance,
      'usage_context': usageContext,
      'jlpt_level': jlptLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// イミュータブルなコピーを作成
  Phrase copyWith({
    int? id,
    String? japanese,
    String? romaji,
    String? indonesian,
    int? categoryId,
    String? audioPath,
    int? importance,
    String? usageContext,
    String? jlptLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Phrase(
      id: id ?? this.id,
      japanese: japanese ?? this.japanese,
      romaji: romaji ?? this.romaji,
      indonesian: indonesian ?? this.indonesian,
      categoryId: categoryId ?? this.categoryId,
      audioPath: audioPath ?? this.audioPath,
      importance: importance ?? this.importance,
      usageContext: usageContext ?? this.usageContext,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Phrase(id: $id, japanese: $japanese, romaji: $romaji, indonesian: $indonesian)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Phrase &&
        other.id == id &&
        other.japanese == japanese &&
        other.romaji == romaji &&
        other.indonesian == indonesian &&
        other.categoryId == categoryId &&
        other.audioPath == audioPath &&
        other.importance == importance &&
        other.usageContext == usageContext &&
        other.jlptLevel == jlptLevel &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      japanese,
      romaji,
      indonesian,
      categoryId,
      audioPath,
      importance,
      usageContext,
      jlptLevel,
      createdAt,
      updatedAt,
    );
  }
}
