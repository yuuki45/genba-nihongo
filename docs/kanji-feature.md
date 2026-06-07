# 現場の漢字 機能仕様書

作成日: 2026-06-06

## 概要

工場の現場で目にする掲示・標識・ラベルの漢字語を学習できる機能。
非漢字圏のインドネシア人技能実習生にとって、「危険」「立入禁止」などの
表示が読めないことは安全に直結する問題であるため、実用性を最優先に設計する。

## 設計方針

- **学習単位は「語」**: 現場の掲示は単漢字ではなく熟語（表示語）単位で目に入るため、
  「立入禁止」を1カードとして扱う（単漢字の分解学習は将来拡張）
- **クイズは動的生成**: 静的なクイズデータは持たず、漢字語データから
  ランダムに誤答選択肢を生成する（コンテンツ追加だけでクイズも増える）
- **既存パターンの流用**: データ同期（data_version）、TTS、お気に入り、
  クイズUIはフレーズ機能の実装パターンを踏襲する

## コンテンツ

### カテゴリ構成（計100語）

| カテゴリキー | 名称(ja) | 名称(id) | 件数 | 例 |
|------------|---------|---------|------|-----|
| safety | 安全標識 | Rambu Keselamatan | 20 | 危険・立入禁止・火気厳禁・消火器 |
| equipment | 設備・操作 | Peralatan & Operasi | 20 | 起動・停止・非常停止・自動/手動 |
| place | 場所・案内 | Tempat & Petunjuk | 20 | 非常口・休憩室・更衣室・受付 |
| work | 品質・作業 | Kualitas & Pekerjaan | 20 | 不良品・検査・出荷・工具・図面 |
| attendance | 勤怠・書類 | Kehadiran & Dokumen | 20 | 出勤・残業・有給・夜勤・朝礼 |

※ 2026-06-07: 60語→100語に拡充（data_version: 2）

### 語データの項目

| 項目 | 説明 |
|------|------|
| id | 一意のID |
| word | 表示語（例: 立入禁止） |
| reading | ひらがな読み（例: たちいりきんし） |
| romaji | ローマ字（例: Tachiiri kinshi） |
| indonesian | インドネシア語訳（例: Dilarang masuk） |
| category | カテゴリキー（safety等） |
| description_ja / description_id | どこで見るかの説明（両言語） |
| importance | 重要度 1-3 |
| jlpt_level | 参考JLPTレベル |

## データモデル

### kanji_words テーブル

```sql
CREATE TABLE kanji_words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word TEXT NOT NULL,
  reading TEXT NOT NULL,
  romaji TEXT NOT NULL,
  indonesian TEXT NOT NULL,
  category TEXT NOT NULL,
  description_ja TEXT,
  description_id TEXT,
  importance INTEGER DEFAULT 1,
  jlpt_level TEXT DEFAULT 'N4',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### kanji_favorites テーブル（苦手漢字）

```sql
CREATE TABLE kanji_favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  kanji_word_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (kanji_word_id) REFERENCES kanji_words(id),
  UNIQUE(kanji_word_id)
);
```

- DBバージョン: 4 → 5（onUpgradeで両テーブルを追加）

### JSONデータ

- 配置: `assets/data/kanji.json`
- 構造: `{ "data_version": 1, "kanji_words": [...] }`
- 同期: フレーズと同様のデータバージョン方式。
  user_settingsの `kanji_data_version` キーとJSONの `data_version` を比較し、
  新しければupsertで差分同期する（`KanjiRepository.syncDataIfNeeded()`）

## 画面構成

```
ホーム画面
└── 「現場の漢字」カード（標識パネルスタイル）
    └── KanjiHomeScreen（漢字メニュー画面）
        ├── KanjiCardScreen（カード学習: カテゴリ選択チップ + スワイプカード）
        │     タップで表裏反転:
        │     表面: 立入禁止（カテゴリのJIS色で標識風に描画）
        │     裏面: たちいりきんし / Tachiiri kinshi / Dilarang masuk
        │           「工場の入口や危険区域で見る」 [TTS再生] [⭐苦手登録]
        ├── KanjiQuizScreen(mode: reading)（読みクイズ: 語 → 読み4択）
        ├── KanjiQuizScreen(mode: meaning)（意味クイズ: 語 → 意味4択）
        ├── KanjiCardScreen(favoritesOnly: true)（苦手漢字の復習）
        └── KanjiQuizScreen(favoritesOnly: true)（苦手クイズ: 読み/意味ミックス）

検索画面（SearchScreen）
└── フレーズと漢字語を横断検索（kanjiSearchResultsProvider）
    └── 漢字語の結果タップ → 標識スタイルの詳細ボトムシート
```

### クイズの動的生成ロジック

1. 出題語からランダムに最大10語を出題
   - 通常クイズ: 全漢字語から / 苦手クイズ: 苦手登録した語から
2. 各問題の誤答3つは「他の語の読み（または意味）」からランダム抽出
   - 苦手クイズでも誤答候補は全語から選ぶ（苦手が少なくても4択が成立）
3. モード未指定（苦手クイズ）の場合は問題ごとに読み/意味をランダムに切り替え
4. 正答位置はシャッフル
5. 回答後に正誤表示 + 語の説明 + ⭐苦手登録トグルを表示
6. 終了後の結果画面に「間違えた語」一覧を表示し、⭐でその場で苦手登録できる
7. 結果はDBに保存しない（セッション内のみ）

## アーキテクチャ

Clean Architecture 3層構造に準拠:

```
lib/
├── data/
│   ├── models/kanji_word.dart            # KanjiWordモデル
│   └── repositories/kanji_repository.dart # ロード・同期・取得・苦手登録
├── presentation/
│   ├── providers/kanji_provider.dart      # Riverpod provider群
│   └── screens/kanji/
│       ├── kanji_home_screen.dart         # 漢字メニュー画面
│       ├── kanji_card_screen.dart         # カード学習画面
│       └── kanji_quiz_screen.dart         # 読み/意味クイズ画面
└── l10n/                                  # kanjiCardTitle 等を追加
```

- 音声: 既存 `TtsService` を流用（読み上げは `word` をTTSに渡す）
- 多言語: UIテキストはARB、データ（説明文）はja/id両方をDBに保存

## 将来拡張（今回スコープ外）

- 書き順アニメーション（KanjiVGストロークデータ導入時）
- 単漢字への分解学習（立入禁止 → 立・入・禁・止）
- JLPTレベル別の体系的漢字学習
- 苦手漢字を優先出題するスマート復習
