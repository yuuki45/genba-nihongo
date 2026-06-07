# UI/UX設計

## デザインシステム

### デザインコンセプト「現場サイネージ」（2026-06-06刷新）

工場の現場標識の視覚言語をそのままデザインシステムとして採用する。
ユーザー（技能実習生）が毎日見ている安全標識とアプリの見た目をつなげることで、
「現場で使える日本語」というアプリの本質を視覚化する。

実装のSingle Source of Truth: `lib/presentation/theme/app_theme.dart`

- **配色**: JIS安全色（黄=注意、赤=禁止、青=指示、緑=安全・避難）+ 墨色 + 紙色
- **タイポグラフィ**: 見出し=Zen Maru Gothic（丸ゴシック、標識の柔らかさ）、
  本文=BIZ UDPゴシック（ユニバーサルデザインフォント — 非母語話者の可読性）
- **シグネチャ要素**: ハザードストライプ（トラ柄）、標識パネル風カード、
  漢字カードの本物標識スタイル（カテゴリ→JIS色マッピング）
- **モーション**: ホーム画面の段階フェードイン（80ms間隔のスタガー）

### カラーパレット

```dart
class AppColors {
  // JIS安全色
  static const Color safetyYellow = Color(0xFFF6C700); // 黄（注意）— メインアクセント
  static const Color jisRed       = Color(0xFFE60012); // 赤（禁止・防火）
  static const Color jisBlue      = Color(0xFF0068B7); // 青（指示）
  static const Color jisGreen     = Color(0xFF00B06B); // 緑（安全状態・避難）

  // ベース
  static const Color ink         = Color(0xFF1C1F26);  // 墨色 — 標識の文字・枠
  static const Color paper       = Color(0xFFF7F5EF);  // 紙色 — ライトモード背景
  static const Color darkSurface = Color(0xFF22252D);  // ダークモードのサーフェス
}
```

**漢字カテゴリ → JIS色マッピング**（実際の標識の配色規則に準拠）:

| カテゴリ | 色 | 根拠 |
|---------|-----|------|
| 安全標識 | 黄/墨 | 注意喚起の標識 |
| 設備・操作 | 青/白 | 指示標識 |
| 場所・案内 | 緑/白 | 避難・案内標識 |
| 品質・作業 | 墨/白 | 一般掲示 |
| 勤怠・書類 | 赤/白 | 重要・期限 |

### タイポグラフィ

```dart
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Japanese Text (larger for readability)
  static const TextStyle japanese = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle romaji = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle translation = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
}
```

### スペーシング

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

## 画面設計

### 1. ホーム画面 (HomeScreen)

**目的**: 今日の学習フレーズを表示し、学習を開始しやすくする

**レイアウト構成**:
```
┌─────────────────────────────┐
│ AppBar: Nihongo              │
│   [通知]         [設定]      │
├─────────────────────────────┤
│                             │
│  📅 今日の日付               │
│  🔥 連続学習: 5日            │
│                             │
│  ┌──────────────────────┐  │
│  │ 今日の3フレーズ        │  │
│  │                      │  │
│  │ 1. おはようございます  │  │
│  │    [▶️ 再生] [⭐]     │  │
│  │                      │  │
│  │ 2. お疲れ様です       │  │
│  │    [▶️ 再生] [⭐]     │  │
│  │                      │  │
│  │ 3. 手伝いましょうか    │  │
│  │    [▶️ 再生] [⭐]     │  │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │ 📊 学習状況           │  │
│  │ ■■■■■□□□□□ 50%  │  │
│  │ 50/100 フレーズ学習済  │  │
│  └──────────────────────┘  │
│                             │
│  [すべてのフレーズを見る]     │
│                             │
├─────────────────────────────┤
│ BottomNav: [ホーム][一覧][履歴] │
└─────────────────────────────┘
```

**主要機能**:
- 今日の3フレーズ表示（日替わり）
- 音声再生ボタン
- お気に入り登録
- 学習進捗表示
- 連続学習日数

### 2. フレーズ一覧画面 (PhraseListScreen)

**目的**: カテゴリ別にフレーズを一覧表示し、検索・フィルタリングを可能にする

**レイアウト構成**:
```
┌─────────────────────────────┐
│ AppBar: フレーズ一覧         │
│   [検索アイコン]             │
├─────────────────────────────┤
│ カテゴリタブ                 │
│ [すべて][挨拶][安全][作業]... │
├─────────────────────────────┤
│                             │
│ ┌─────────────────────────┐ │
│ │ 👋 おはようございます    │ │
│ │ Ohayou gozaimasu        │ │
│ │ Selamat pagi       [▶️] │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ 👋 こんにちは           │ │
│ │ Konnichiwa             │ │
│ │ Selamat siang      [▶️] │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ ⚠️ 危ないです           │ │
│ │ Abunai desu            │ │
│ │ Bahaya             [▶️] │ │
│ └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

**主要機能**:
- カテゴリタブでフィルタリング
- 検索機能
- 各フレーズカードをタップで詳細画面へ
- 音声クイック再生
- スクロール可能なリスト

### 3. フレーズ詳細画面 (PhraseDetailScreen)

**目的**: フレーズの詳細情報を表示し、学習機能を提供

**レイアウト構成**:
```
┌─────────────────────────────┐
│ AppBar: [戻る]    [⭐お気に入り] │
├─────────────────────────────┤
│                             │
│  カテゴリ: 👋 あいさつ        │
│                             │
│  ┌──────────────────────┐  │
│  │   おはようございます    │  │
│  │   Ohayou gozaimasu    │  │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │  🇮🇩 Selamat pagi     │  │
│  └──────────────────────┘  │
│                             │
│  📝 使用場面:                │
│  朝の挨拶（出勤時に使用）      │
│                             │
│  ┌──────────────────────┐  │
│  │  [🔊 音声を聞く]       │  │
│  │  速度: [遅い] [普通] [速い] │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │  [🎤 発音を練習]       │  │
│  │  タップして録音開始      │  │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │ 🎯 発音スコア: 85点     │  │
│  │ [もう一度]           │  │
│  └──────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**主要機能**:
- 日本語フレーズ表示
- ローマ字表示
- 翻訳表示
- 音声再生（速度調整可能）
- 録音機能
- 発音評価（将来的に）
- お気に入り登録
- 使用場面の説明

### 4. 学習履歴画面 (HistoryScreen)

**目的**: 学習の進捗を可視化し、モチベーション維持

**レイアウト構成**:
```
┌─────────────────────────────┐
│ AppBar: 学習履歴             │
├─────────────────────────────┤
│                             │
│  ┌──────────────────────┐  │
│  │ 📊 統計情報           │  │
│  │                      │  │
│  │ 学習済み: 50/100      │  │
│  │ 連続学習: 5日         │  │
│  │ 今週: 15フレーズ       │  │
│  └──────────────────────┘  │
│                             │
│  📅 カレンダービュー          │
│  月 火 水 木 金 土 日         │
│  ✓  ✓  ✓  ✓  ✓  -  -       │
│                             │
│  📝 最近の学習               │
│  ┌──────────────────────┐  │
│  │ 2024/10/15           │  │
│  │ おはようございます ✓   │  │
│  │ こんにちは ✓          │  │
│  └──────────────────────┘  │
│                             │
│  ┌──────────────────────┐  │
│  │ 2024/10/14           │  │
│  │ お疲れ様です ✓        │  │
│  └──────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**主要機能**:
- 学習統計表示
- カレンダービュー
- 学習履歴リスト
- 連続学習日数
- 週次・月次統計

### 5. 設定画面 (SettingsScreen)

**目的**: アプリの設定を管理

**レイアウト構成**:
```
┌─────────────────────────────┐
│ AppBar: 設定                 │
├─────────────────────────────┤
│                             │
│  言語設定                    │
│  ┌──────────────────────┐  │
│  │ 日本語 / Indonesia    │  │
│  └──────────────────────┘  │
│                             │
│  音声設定                    │
│  ┌──────────────────────┐  │
│  │ 再生速度: 普通        │  │
│  │ [遅い][普通][速い]     │  │
│  └──────────────────────┘  │
│                             │
│  通知設定                    │
│  ┌──────────────────────┐  │
│  │ 学習リマインド [ON]    │  │
│  │ 時刻: 21:00          │  │
│  └──────────────────────┘  │
│                             │
│  データ管理                  │
│  ┌──────────────────────┐  │
│  │ [学習履歴をリセット]    │  │
│  │ [データを再読込]       │  │
│  └──────────────────────┘  │
│                             │
│  アプリ情報                  │
│  バージョン: 1.0.0           │
│                             │
└─────────────────────────────┘
```

**主要機能**:
- 言語切替（日本語/インドネシア語）
- 音声速度調整
- 通知設定
- 学習履歴リセット
- アプリ情報表示

## コンポーネント設計

### PhraseCard

フレーズを表示するカードコンポーネント

```dart
Widget PhraseCard({
  required Phrase phrase,
  VoidCallback? onTap,
  VoidCallback? onPlayAudio,
  bool showCategory = false,
})
```

### AudioPlayerWidget

音声再生用のウィジェット

```dart
Widget AudioPlayerWidget({
  required String audioPath,
  PlaybackSpeed speed = PlaybackSpeed.normal,
})
```

### RecorderWidget

録音用のウィジェット

```dart
Widget RecorderWidget({
  required Function(String) onRecordingComplete,
})
```

### ProgressIndicator

学習進捗を表示するウィジェット

```dart
Widget ProgressIndicator({
  required int current,
  required int total,
})
```

## アニメーション

- カード表示: Fade + Slide アニメーション
- ボタンタップ: スケールアニメーション
- 画面遷移: Material標準のトランジション
- 音声再生中: Lottieアニメーション（音波表現）

## アクセシビリティ

- 最小タップエリア: 44x44 px
- コントラスト比: WCAG AA基準準拠
- スクリーンリーダー対応
- フォントサイズ調整可能
