# データモデル設計

## データベーススキーマ

### phrases テーブル

フレーズの基本情報を格納

```sql
CREATE TABLE phrases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  japanese TEXT NOT NULL,              -- 日本語フレーズ
  romaji TEXT NOT NULL,                -- ローマ字読み
  indonesian TEXT NOT NULL,            -- インドネシア語翻訳
  category_id INTEGER NOT NULL,        -- カテゴリID
  audio_path TEXT,                     -- 音声ファイルパス
  importance INTEGER DEFAULT 1,        -- 重要度 (1-3)
  usage_context TEXT,                  -- 使用場面の説明
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

### categories テーブル

フレーズのカテゴリ情報

```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name_ja TEXT NOT NULL,               -- カテゴリ名（日本語）
  name_id TEXT NOT NULL,               -- カテゴリ名（インドネシア語）
  icon TEXT,                           -- アイコン名
  sort_order INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
);
```

### favorites テーブル

お気に入りフレーズ

```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  phrase_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (phrase_id) REFERENCES phrases(id)
);
```

### user_settings テーブル

ユーザー設定

```sql
CREATE TABLE user_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

## Dartモデルクラス

### Phrase モデル

```dart
class Phrase {
  final int? id;
  final String japanese;
  final String romaji;
  final String indonesian;
  final int categoryId;
  final String? audioPath;
  final int importance;
  final String? usageContext;
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
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON変換
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // データベース変換
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // copyWith
  Phrase copyWith({
    int? id,
    String? japanese,
    String? romaji,
    String? indonesian,
    int? categoryId,
    String? audioPath,
    int? importance,
    String? usageContext,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### Category モデル

```dart
class Category {
  final int? id;
  final String nameJa;
  final String nameId;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;

  Category({
    this.id,
    required this.nameJa,
    required this.nameId,
    this.icon,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      nameJa: json['name_ja'] as String,
      nameId: json['name_id'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ja': nameJa,
      'name_id': nameId,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      nameJa: map['name_ja'] as String,
      nameId: map['name_id'] as String,
      icon: map['icon'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ja': nameJa,
      'name_id': nameId,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

## JSONデータフォーマット

### phrases.json

初期データとして使用するフレーズ集

```json
{
  "categories": [
    {
      "id": 1,
      "name_ja": "あいさつ",
      "name_id": "Salam",
      "icon": "👋",
      "sort_order": 1
    },
    {
      "id": 2,
      "name_ja": "安全",
      "name_id": "Keselamatan",
      "icon": "⚠️",
      "sort_order": 2
    },
    {
      "id": 3,
      "name_ja": "作業指示",
      "name_id": "Instruksi Kerja",
      "icon": "🔧",
      "sort_order": 3
    }
  ],
  "phrases": [
    {
      "id": 1,
      "japanese": "おはようございます",
      "romaji": "Ohayou gozaimasu",
      "indonesian": "Selamat pagi",
      "category_id": 1,
      "audio_path": "audio/phrase_001.mp3",
      "importance": 3,
      "usage_context": "朝の挨拶（出勤時）"
    },
    {
      "id": 2,
      "japanese": "危ないです",
      "romaji": "Abunai desu",
      "indonesian": "Bahaya",
      "category_id": 2,
      "audio_path": "audio/phrase_002.mp3",
      "importance": 3,
      "usage_context": "危険を知らせる時"
    }
  ]
}
```

## データフロー

```
JSON(assets) → Repository → Database(sqflite)
                    ↓
                  Domain
                    ↓
              Presentation(UI)
```

1. 初回起動時にJSONからデータを読み込み
2. ローカルDBに保存
3. 以降はローカルDBから読み込み
