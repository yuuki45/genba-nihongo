# プロジェクト構造設計

## ディレクトリ構成

```
nihongo/
├── lib/
│   ├── main.dart                 # アプリケーションエントリーポイント
│   ├── app/
│   │   ├── app.dart              # MaterialAppの設定
│   │   └── routes.dart           # ルーティング設定
│   ├── core/
│   │   ├── constants/            # 定数定義
│   │   │   ├── app_constants.dart
│   │   │   ├── colors.dart
│   │   │   └── text_styles.dart
│   │   ├── utils/                # ユーティリティ関数
│   │   │   ├── date_utils.dart
│   │   │   └── audio_utils.dart
│   │   └── services/             # コアサービス
│   │       ├── storage_service.dart
│   │       ├── notification_service.dart
│   │       └── audio_service.dart
│   ├── data/
│   │   ├── models/               # データモデル
│   │   │   ├── phrase.dart
│   │   │   ├── category.dart
│   │   │   └── learning_history.dart
│   │   ├── repositories/         # リポジトリ層
│   │   │   ├── phrase_repository.dart
│   │   │   └── history_repository.dart
│   │   └── datasources/          # データソース
│   │       ├── local/
│   │       │   ├── database_helper.dart
│   │       │   └── shared_prefs_helper.dart
│   │       └── remote/
│   │           └── api_client.dart (将来的に)
│   ├── domain/
│   │   ├── entities/             # ビジネスエンティティ
│   │   └── usecases/             # ユースケース
│   │       ├── get_daily_phrases.dart
│   │       ├── play_audio.dart
│   │       └── record_audio.dart
│   ├── presentation/
│   │   ├── screens/              # 画面
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── phrases/
│   │   │   │   ├── phrase_list_screen.dart
│   │   │   │   ├── phrase_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── history/
│   │   │   │   ├── history_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── settings/
│   │   │       ├── settings_screen.dart
│   │   │       └── widgets/
│   │   ├── widgets/              # 共通ウィジェット
│   │   │   ├── audio_player_widget.dart
│   │   │   ├── phrase_card.dart
│   │   │   └── progress_indicator.dart
│   │   └── providers/            # 状態管理（Riverpod）
│   │       ├── phrase_provider.dart
│   │       ├── audio_provider.dart
│   │       └── settings_provider.dart
│   └── l10n/                     # 多言語対応
│       ├── app_ja.arb
│       └── app_id.arb
├── assets/
│   ├── audio/                    # 音声ファイル
│   ├── images/                   # 画像ファイル
│   └── data/                     # JSONデータ
│       └── phrases.json
├── test/                         # テストコード
│   ├── unit/
│   ├── widget/
│   └── integration/
└── docs/                         # ドキュメント
    ├── readme.md
    ├── project-structure.md
    ├── api-design.md
    ├── data-model.md
    ├── ui-design.md
    ├── roadmap.md
    └── tech-stack.md
```

## アーキテクチャパターン

### Clean Architecture + MVVM

このプロジェクトでは、Clean Architectureの原則に基づいて、以下の3層構造を採用します：

1. **Presentation層** (`presentation/`)
   - UI/UX担当
   - 状態管理（Riverpod）
   - ユーザーインタラクション処理

2. **Domain層** (`domain/`)
   - ビジネスロジック
   - エンティティ定義
   - ユースケース

3. **Data層** (`data/`)
   - データの取得・保存
   - リポジトリパターン
   - ローカル/リモートデータソース

## 主要コンポーネント

### 状態管理

- **Riverpod** を使用
- Provider単位で状態を管理
- 依存性注入を容易に

### ルーティング

- **go_router** を使用
- 宣言的なルーティング
- ディープリンク対応

### ローカルストレージ

- **shared_preferences**: 設定情報
- **sqflite**: 学習履歴・お気に入り
- **path_provider**: ファイルパス取得

### 音声処理

- **audioplayers**: 音声再生
- **flutter_tts**: Text-to-Speech
- **record**: 音声録音
- **speech_to_text**: 音声認識（将来的に）

## 開発規約

### 命名規則

- ファイル名: `snake_case`
- クラス名: `PascalCase`
- 変数・関数名: `camelCase`
- 定数: `UPPER_SNAKE_CASE`

### コードスタイル

- Dart標準のlintルールに従う
- `flutter analyze` でエラーゼロを維持
- コメントは日本語で記述

### Git運用

- ブランチ戦略: Git Flow
  - `main`: 本番リリース
  - `develop`: 開発版
  - `feature/*`: 機能開発
  - `fix/*`: バグ修正
- コミットメッセージは日本語で記述
