# 技術スタック一覧

## 開発環境

### Flutter SDK

- **バージョン**: 3.24.0以上（安定版最新）
- **Dart SDK**: 3.5.0以上
- **対応プラットフォーム**: iOS 12.0+, Android 5.0+ (API Level 21+)

### IDE

- **推奨**: Visual Studio Code
  - Flutter拡張機能
  - Dart拡張機能
- **代替**: Android Studio

## コアパッケージ

### 状態管理

```yaml
flutter_riverpod: ^2.5.1
```

**選定理由**:
- シンプルで学習コストが低い
- 依存性注入が容易
- テストしやすい
- パフォーマンスが良い

### ルーティング

```yaml
go_router: ^14.2.0
```

**選定理由**:
- 宣言的なルーティング
- ディープリンク対応
- 型安全
- ナビゲーションガードのサポート

## データ管理

### ローカルデータベース

```yaml
sqflite: ^2.3.3
path_provider: ^2.1.3
```

**用途**:
- フレーズデータの永続化
- 学習履歴の保存
- お気に入り管理

### Key-Value ストレージ

```yaml
shared_preferences: ^2.2.3
```

**用途**:
- ユーザー設定の保存
- 言語設定
- 音声速度設定
- 通知設定

## 音声関連

### 音声再生

```yaml
audioplayers: ^6.0.0
```

**機能**:
- MP3/AAC音声ファイルの再生
- 再生速度調整
- 一時停止・再開
- シーク機能

### Text-to-Speech

```yaml
flutter_tts: ^4.0.2
```

**機能**:
- 日本語音声合成
- 音声速度調整
- 音量調整
- 多言語対応

### 音声録音

```yaml
record: ^5.1.0
```

**機能**:
- 音声録音
- 録音データの保存
- 録音時間制限
- 音声フォーマット指定

### 音声認識（将来的に）

```yaml
speech_to_text: ^6.6.2
```

**機能**:
- 音声認識
- リアルタイム文字起こし
- 多言語対応

## UI/UXライブラリ

### アニメーション

```yaml
lottie: ^3.1.2
```

**用途**:
- ローディングアニメーション
- 音声再生中のビジュアル
- 成功/エラーフィードバック

### アイコン

```yaml
flutter_svg: ^2.0.10
cupertino_icons: ^1.0.8
```

**用途**:
- SVGアイコンの表示
- iOS標準アイコン

### カラーピッカー・UI補助

```yaml
flutter_colorpicker: ^1.1.0
shimmer: ^3.0.0
```

**用途**:
- ローディング時のシマーエフェクト
- カラーカスタマイズ（将来的に）

## 多言語対応

### 国際化（i18n）

```yaml
flutter_localizations:
  sdk: flutter
intl: ^0.19.0
```

**対応言語**:
- 日本語（ja）
- インドネシア語（id）

## 通知

### ローカル通知

```yaml
flutter_local_notifications: ^17.2.1
```

**機能**:
- 学習リマインド通知
- スケジュール通知
- 通知カスタマイズ

### タイムゾーン

```yaml
timezone: ^0.9.3
```

**用途**:
- 通知のスケジューリング
- タイムゾーン対応

## ユーティリティ

### 日付操作

```yaml
intl: ^0.19.0
```

**機能**:
- 日付フォーマット
- 相対時間表示
- ロケール対応

### JSON処理

```yaml
json_annotation: ^4.9.0
json_serializable: ^6.8.0
```

**用途**:
- JSONシリアライゼーション
- モデルクラスの自動生成

### HTTP通信（将来的に）

```yaml
http: ^1.2.1
dio: ^5.4.3
```

**用途**:
- API通信
- ファイルダウンロード
- エラーハンドリング

## 開発ツール

### コード生成

```yaml
build_runner: ^2.4.9
freezed: ^2.5.2
freezed_annotation: ^2.4.1
```

**用途**:
- イミュータブルクラスの生成
- copyWithメソッドの自動生成
- JSONシリアライゼーション

### Linter

```yaml
flutter_lints: ^4.0.0
```

**機能**:
- Dart標準のlintルール
- コード品質の維持
- ベストプラクティスの強制

## テスト

### ユニットテスト

```yaml
flutter_test:
  sdk: flutter
mockito: ^5.4.4
```

**用途**:
- ビジネスロジックのテスト
- モデルクラスのテスト
- リポジトリのテスト

### ウィジェットテスト

```yaml
flutter_test:
  sdk: flutter
```

**用途**:
- UIコンポーネントのテスト
- ウィジェットの動作確認

### 統合テスト

```yaml
integration_test:
  sdk: flutter
```

**用途**:
- エンドツーエンドテスト
- ユーザーフローのテスト

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: flutter analyze
```

## バージョン管理

### Git

- **リポジトリ**: GitHub
- **ブランチ戦略**: Git Flow
  - `main`: 本番リリース
  - `develop`: 開発版
  - `feature/*`: 機能開発
  - `fix/*`: バグ修正

## ビルド・デプロイ

### Android

- **ビルドツール**: Gradle 8.0+
- **最小SDK**: API Level 21 (Android 5.0)
- **ターゲットSDK**: API Level 34 (Android 14)
- **署名**: Play App Signing

### iOS

- **最小バージョン**: iOS 12.0
- **ビルドツール**: Xcode 15.0+
- **署名**: App Store Connect

## アセット管理

### 音声ファイル

- **フォーマット**: MP3（128kbps）
- **サンプリングレート**: 44.1kHz
- **チャンネル**: モノラル
- **ファイルサイズ**: 約50-100KB/ファイル

### 画像

- **フォーマット**: PNG, SVG
- **アイコン**: SVG推奨
- **写真**: WebP推奨（将来的に）

## パフォーマンス最適化

### 画像最適化

```yaml
flutter_native_splash: ^2.4.0
```

**用途**:
- スプラッシュスクリーンの最適化
- ネイティブスプラッシュの生成

### キャッシュ

```yaml
cached_network_image: ^3.3.1
```

**用途**:
- ネットワーク画像のキャッシュ
- パフォーマンス向上

## セキュリティ

### 暗号化（将来的に）

```yaml
flutter_secure_storage: ^9.2.2
```

**用途**:
- 機密情報の安全な保存
- トークン管理

## 分析・モニタリング（将来的に）

### クラッシュレポート

```yaml
firebase_crashlytics: ^3.5.5
```

### アナリティクス

```yaml
firebase_analytics: ^10.10.5
```

## pubspec.yaml 完全版

```yaml
name: nihongo
description: 現場にほんご - 外国人技能実習生向け日本語学習アプリ
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # 状態管理
  flutter_riverpod: ^2.5.1

  # ルーティング
  go_router: ^14.2.0

  # データ管理
  sqflite: ^2.3.3
  path_provider: ^2.1.3
  shared_preferences: ^2.2.3

  # 音声
  audioplayers: ^6.0.0
  flutter_tts: ^4.0.2
  record: ^5.1.0

  # UI/UX
  lottie: ^3.1.2
  flutter_svg: ^2.0.10
  cupertino_icons: ^1.0.8
  shimmer: ^3.0.0

  # 通知
  flutter_local_notifications: ^17.2.1
  timezone: ^0.9.3

  # ユーティリティ
  intl: ^0.19.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  # コード生成
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
  freezed: ^2.5.2
  freezed_annotation: ^2.4.1

  # Linter
  flutter_lints: ^4.0.0

  # テスト
  mockito: ^5.4.4

flutter:
  uses-material-design: true

  assets:
    - assets/audio/
    - assets/images/
    - assets/data/

  fonts:
    - family: NotoSansJP
      fonts:
        - asset: fonts/NotoSansJP-Regular.ttf
        - asset: fonts/NotoSansJP-Bold.ttf
          weight: 700
```

## 推奨開発ツール

- **バージョン管理**: Git + GitHub
- **API テスト**: Postman（将来的にAPI実装時）
- **デザイン**: Figma
- **プロジェクト管理**: GitHub Projects
- **コミュニケーション**: Slack / Discord
- **ドキュメント**: Markdown (GitHub)

## システム要件

### 開発マシン

- **OS**: macOS (iOS開発の場合必須), Windows, Linux
- **RAM**: 8GB以上（推奨16GB）
- **ストレージ**: 10GB以上の空き容量
- **プロセッサ**: Intel Core i5以上 / Apple Silicon

### 実行環境

- **iOS**: iPhone 6s以降、iOS 12.0以上
- **Android**: Android 5.0 (Lollipop) 以降、RAM 2GB以上
