# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際にClaude Code (claude.ai/code) にガイダンスを提供します。

## 重要な作業指針

### ドキュメント参照の徹底

**すべての実装・変更作業を開始する前に、必ず `docs/` フォルダ内の関連ドキュメントを参照してください。**

- 機能実装前: 該当する仕様書を確認
- データモデル作成時: `docs/data-model.md` を参照
- UI実装時: `docs/ui-design.md` を参照
- 技術選定時: `docs/tech-stack.md` を参照
- アーキテクチャ確認時: `docs/project-structure.md` を参照

### タスク完了時の確認事項

タスクを完了したと判断する前に、以下を必ず確認してください：

1. **実装の完全性**
   - 要件定義通りに実装されているか
   - エラーハンドリングは適切か
   - エッジケースに対応しているか

2. **コード品質**
   - `flutter analyze` でエラーがないか
   - `flutter test` ですべてのテストが通るか
   - コーディング規約に従っているか

3. **ドキュメントとの整合性**
   - `docs/` 内の仕様書と一致しているか
   - 変更がある場合、ドキュメントも更新したか

4. **動作確認**
   - 実装した機能が正常に動作するか
   - 関連する既存機能に影響がないか

5. **ユーザーへの報告**
   - 実装内容を明確に説明
   - 動作確認の方法を提示
   - 残課題があれば明示

## プロジェクト概要

**Nihongo** - 日本の工場で働くインドネシア人技能実習生向けの日本語学習モバイルアプリ。音声再生、発音練習、翻訳機能を通じて、現場で必要な日本語フレーズを学習できます。

**現在のステータス**: プロジェクトは計画段階です。`docs/`にドキュメントは存在しますが、Flutterアプリのコードはまだ実装されていません。

## プロジェクトアーキテクチャ

このFlutterアプリは**Clean Architecture**に従い、3層構造を採用しています：

### 層構造

1. **Presentation層** (`lib/presentation/`)
   - UIコンポーネントと画面
   - Riverpodを使用した状態管理
   - 状態管理用のProvider

2. **Domain層** (`lib/domain/`)
   - ビジネスロジック
   - ユースケース（例: `get_daily_phrases`, `play_audio`, `record_audio`）
   - ビジネスエンティティ

3. **Data層** (`lib/data/`)
   - リポジトリパターンの実装
   - データソース（ローカル: sqflite, shared_preferences）
   - JSON/DB シリアライゼーション対応のデータモデル

### 主要技術

- **状態管理**: flutter_riverpod
- **ルーティング**: go_router
- **ローカルDB**: sqflite（フレーズ、学習履歴、お気に入り用）
- **ローカルストレージ**: shared_preferences（ユーザー設定用）
- **音声**: audioplayers（再生）, flutter_tts（TTS）
- **多言語対応**: 日本語（ja）とインドネシア語（id）

## データモデル

アプリはJSONとsqfliteの両方にマッピングされる3つのコアデータモデルを使用します：

- **Phrase**: 日本語フレーズ、ローマ字、インドネシア語翻訳、音声パス、重要度、使用場面
- **Category**: フレーズカテゴリ（あいさつ、安全、作業指示など）
- **LearningHistory**: ユーザーの進捗を追跡（listened/practiced/mastered）

すべてのモデルには以下が含まれます：
- `fromJson()` / `toJson()` - JSONシリアライゼーション用
- `fromMap()` / `toMap()` - データベース操作用
- `copyWith()` - イミュータビリティ用

完全なスキーマ定義は`docs/data-model.md`を参照してください。

## 開発ワークフロー

### 初期セットアップ（実装時）

```bash
# Flutterプロジェクト作成（存在しない場合）
flutter create --org com.genba --project-name nihongo .

# 依存関係の取得
flutter pub get

# コード生成（json_serializable, freezed用）
flutter pub run build_runner build --delete-conflicting-outputs
```

### 開発コマンド

```bash
# アプリ実行（開発モード）
flutter run

# 特定のデバイスで実行
flutter run -d <device_id>

# ホットリロード（実行中）
# ターミナルで 'r' を押す

# ホットリスタート
# ターミナルで 'R' を押す

# フレーバー指定で実行（実装時）
flutter run --flavor dev -t lib/main_dev.dart
```

### コード品質

```bash
# コード解析
flutter analyze

# コードフォーマット
flutter format .

# すべてのテスト実行
flutter test

# カバレッジ付きテスト実行
flutter test --coverage

# 特定のテストファイル実行
flutter test test/unit/models/phrase_test.dart

# ウィジェットテスト実行
flutter test test/widget/

# 統合テスト実行
flutter test integration_test/
```

### コード生成

```bash
# 継続的な生成のためのウォッチモード
flutter pub run build_runner watch

# ワンタイム生成
flutter pub run build_runner build --delete-conflicting-outputs
```

### ビルドコマンド

```bash
# APKビルド（Android）
flutter build apk --release

# App Bundleビルド（Android）
flutter build appbundle --release

# iOSビルド
flutter build ios --release

# 特定のフレーバーでビルド
flutter build apk --flavor prod -t lib/main_prod.dart
```

## コーディング規約

### 命名規則

- ファイル名: `snake_case.dart`
- クラス名: `PascalCase`
- 変数・関数名: `camelCase`
- 定数: `UPPER_SNAKE_CASE`
- プライベートメンバー: `_`でプレフィックス

### コメント

- コメントは**日本語**で記述
- パブリックAPIと複雑なロジックをドキュメント化
- ドキュメントコメントには`///`を使用

### ファイル構成

Clean Architectureの層に従って新しいファイルを配置：
- モデル: `lib/data/models/`
- リポジトリ: `lib/data/repositories/`
- ユースケース: `lib/domain/usecases/`
- 画面: `lib/presentation/screens/<feature_name>/`
- ウィジェット: `lib/presentation/widgets/`（共通）または画面フォルダ内
- Provider: `lib/presentation/providers/`

## 実装上の重要な注意点

### データフロー

1. **初回読み込み**: JSON（`assets/data/phrases.json`）→ Repository → sqfliteデータベース
2. **以降の読み込み**: sqflite → Repository → Domain → Presentation
3. **ユーザーデータ**: 学習履歴とお気に入りはsqfliteのみに保存

### 音声ファイル

- フォーマット: MP3（128kbps, 44.1kHz, モノラル）
- 配置場所: `assets/audio/phrase_XXX.mp3`
- 想定サイズ: 50-100KB/ファイル
- 合計: 100フレーズ分の音声ファイルが必要

### 多言語対応

アプリは日本語（ja）とインドネシア語（id）をサポート：
- ARBファイル: `lib/l10n/app_ja.arb`, `lib/l10n/app_id.arb`
- UIテキストはローカライゼーション文字列を使用
- データベースコンテンツ（フレーズ）は両言語で保存

### 状態管理パターン

Riverpod providerを以下の用途で使用：
- データ取得とキャッシング
- UI状態（loading, error, success）
- 依存性注入

パターン例:
```dart
final phraseProvider = StateNotifierProvider<PhraseNotifier, PhraseState>((ref) {
  final repository = ref.watch(phraseRepositoryProvider);
  return PhraseNotifier(repository);
});
```

### リポジトリパターン

リポジトリはデータソースを抽象化します：
- データモデルではなくドメインエンティティを返す
- エラーケースを処理し、Result/Either型を返す
- 適切な場合はデータをキャッシュする

## Git運用

**ブランチ戦略**: Git Flow
- `main`: 本番リリースのみ
- `develop`: 開発ブランチ
- `feature/*`: 新機能
- `fix/*`: バグ修正

**コミットメッセージ**: 日本語で記述

## テスト戦略

- **ユニットテスト**: すべてのモデル、リポジトリ、ユースケース
- **ウィジェットテスト**: 再利用可能なウィジェットと複雑なUIコンポーネント
- **統合テスト**: 重要なユーザーフロー（フレーズ再生、録音、学習履歴）
- **目標カバレッジ**: 80%以上

## 参考資料

包括的なドキュメントは`docs/`にあります：
- `docs/readme.md`: 要件と機能
- `docs/project-structure.md`: ディレクトリ構造とアーキテクチャ
- `docs/data-model.md`: データベーススキーマとモデルクラス
- `docs/ui-design.md`: デザインシステムと画面レイアウト
- `docs/tech-stack.md`: 完全なパッケージリストとバージョン
- `docs/roadmap.md`: 12週間の開発計画

機能を実装する際は、これらのドキュメントを参照して詳細な仕様を確認してください。
