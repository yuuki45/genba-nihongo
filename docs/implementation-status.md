# 実装状況レポート

最終更新: 2026-06-06

## ✅ 完了した機能

### フェーズ1: 基盤構築 (Week 1-2) - 100% 完了

#### Week 1: プロジェクトセットアップ
- ✅ プロジェクト要件定義
- ✅ ドキュメント作成（readme.md, data-model.md, ui-design.md, tech-stack.md, project-structure.md, roadmap.md）
- ✅ Flutterプロジェクト初期化
- ✅ 必要パッケージのインストール（flutter_riverpod, sqflite, flutter_tts, etc.）
- ✅ プロジェクト構造の作成（Clean Architecture準拠）

#### Week 2: データモデル・リポジトリ実装
- ✅ データモデルクラス（Phrase, Category, Quiz）
- ✅ データベース設計・実装（sqflite）
- ✅ リポジトリパターン実装（PhraseRepository, QuizRepository）
- ✅ 初期データ（329フレーズ）のJSON作成
- ✅ データロード機能

### フェーズ2: コア機能開発 (Week 3-6) - 100% 完了

#### Week 3: ホーム画面・ナビゲーション
- ✅ BottomNavigationBar実装（4タブ: ホーム、一覧、お気に入り、設定）
- ✅ ホーム画面UI（今日の3フレーズ表示）
- ✅ 状態管理セットアップ（Riverpod）

#### Week 4: フレーズ一覧・詳細画面
- ✅ フレーズ一覧画面（カテゴリタブ、JLPTレベルタブ、フレーズカード）
- ✅ フレーズ詳細画面（日本語・ひらがな・ローマ字・翻訳表示）
- ✅ カテゴリフィルタリング機能
- ✅ JLPTレベルフィルタリング機能
- ✅ 検索機能

#### Week 5: 音声機能実装
- ✅ TTS（Text-to-Speech）機能（flutter_tts）
- ✅ 日本語音声合成
- ✅ 音声再生UI

#### Week 6: お気に入り機能
- ✅ お気に入り登録/解除
- ✅ お気に入り一覧表示
- ✅ sqfliteによる永続化

### フェーズ3: 補助機能・改善 (Week 7-8) - 100% 完了 ✅

#### Week 7: 設定・法的ページ ✅
- ✅ **設定画面UI実装**
  - ✅ 言語切替（日本語 ⇄ インドネシア語）
  - ✅ ダークモード切替
  - ✅ アプリバージョン表示（1.0.0）
  - ✅ アプリ情報表示（フレーズ数: 329、開発者情報）
  - ✅ オフライン対応ステータス表示
  - ✅ アプリについてダイアログ

- ✅ **多言語対応（i18n）**
  - ✅ 日本語（ja）
  - ✅ インドネシア語（id）
  - ✅ ARBファイル実装
  - ✅ SharedPreferencesによる設定保存
  - ✅ アプリ全体への即座の反映

- ✅ **法的ページの実装**
  - ✅ 利用規約ページ
    - 日本語版（第1条〜第8条）
    - インドネシア語版（Pasal 1〜8）
  - ✅ プライバシーポリシーページ
    - 個人情報の収集・利用目的・第三者提供・管理
    - 完全オフラインであることの明記
    - 日本語・インドネシア語対応
  - ✅ お問い合わせページ
    - メールアドレス表示（web-studio@ymail.ne.jp）
    - クリップボードへのコピー機能
    - 注意事項表示（日本語・インドネシア語）

#### Week 8: オフライン対応・パフォーマンス最適化 ✅
- ✅ オフライン機能確認
  - 完全オフライン動作（sqfliteによるローカルDB）
  - インターネット接続不要
- ✅ エラーハンドリング改善
  - 共通エラー表示ウィジェット（ErrorView, EmptyView）
  - TtsServiceのエラーハンドリング強化
  - エラー情報の保存と取得
- ✅ ローディング状態の改善
  - 共通ローディングウィジェット（LoadingView）
  - スケルトンウィジェット（SkeletonCard, SkeletonListItem）
- ✅ コード品質の改善
  - `print`文を`debugPrint`に置き換え
  - すべての警告を修正（Flutter Analyze: No issues found!）
  - `use_build_context_synchronously`警告の修正

### 追加実装された機能（ボーナス）

#### クイズ機能 ✅
- ✅ クイズデータモデル（Quiz）
- ✅ クイズリポジトリ（QuizRepository）
- ✅ クイズ画面UI
- ✅ クイズプロバイダー

#### N2レベル対応 ✅（2026-06-06追加）
- ✅ N2フレーズ49件を追加（現場の敬語・報告系 + 生活・手続き系）
  - あいさつ: 5件、安全: 8件、作業指示: 18件、日常会話: 14件、緊急: 4件
  - ※当初50件だったが「お世話になっております」がN3と重複していたため1件削除（data_version: 3）
- ✅ データ同期に削除処理を追加（JSONから消したフレーズが既存ユーザーのDBからも消える）
- ✅ フレーズ一覧のJLPTレベルタブにN2を追加
- ✅ データバージョン管理によるデータ同期機構
  - `phrases.json` に `data_version` フィールドを追加（現在: 3）
  - 起動時にDBの保存バージョンと比較し、新しければ差分を同期（`PhraseRepository.syncDataIfNeeded()`）
  - 既存ユーザーのDBにもアプリ更新で新フレーズが反映される

#### 現場の漢字（漢字学習機能） ✅（2026-06-06追加）
詳細仕様: `docs/kanji-feature.md`
- ✅ 漢字語データ60語（`assets/data/kanji.json`、データバージョン管理対応）
  - 安全標識 / 設備・操作 / 場所・案内 / 品質・作業 / 勤怠・書類（各12語）
- ✅ KanjiWordモデル・KanjiRepository・kanji_words/kanji_favoritesテーブル（DB v4→v5）
- ✅ 漢字カード学習画面（カテゴリチップ + タップで表裏反転 + TTS再生）
- ✅ 読みクイズ・意味クイズ（漢字語データから4択を動的生成、静的クイズデータ不要）
- ✅ 苦手漢字の登録・復習（kanji_favoritesテーブル）
- ✅ ホーム画面に「現場の漢字」導線カードを追加
- ✅ 多言語対応（ARBに漢字機能の文言を追加、説明文はja/id両方をデータに保持）

#### UI刷新「現場サイネージ」デザイン ✅（2026-06-06追加・Week 10前倒し）
詳細: `docs/ui-design.md` のデザインシステム
- ✅ JIS安全色ベースのテーマシステム（`lib/presentation/theme/app_theme.dart`、light/dark対応）
- ✅ フォントバンドル: Zen Maru Gothic（見出し）+ BIZ UDPゴシック（本文、約16MB増）
- ✅ ホーム画面刷新（墨色ヒーローヘッダー + ハザードストライプ + 段階フェードイン + 標識パネル風カード）
- ✅ 漢字カードを本物のJIS標識スタイルで描画（カテゴリ→JIS色マッピング）

#### ホーム画面UX改善 ✅（2026-06-07追加）
- ✅ 言語切替をセグメントコントロール化（両言語常時表示・国旗付き・インドネシア語先頭）
- ✅ 初回起動のデフォルト言語をインドネシア語（id）に変更
- ✅ 日付表示を表示言語に追従（ja: 2026年06月07日(日) / id: Minggu, 7 Juni 2026）
- ✅ あいさつを時間帯対応（朝/昼/夕/夜、シフト勤務に対応）
- ✅ 「今日の3フレーズ」を日付シードで決定的に選択（本当の日替わりに）
- ✅ TTS再生中の視覚フィードバック（停止アイコン・色変化・多重発話防止）
- ✅ 再生ボタンにツールチップ（playAudio/stopAudio、アクセシビリティ向上）
- ✅ 日替わり選択ロジックのユニットテスト8件追加（計52テスト）
- ✅ フレーズ一覧のカテゴリチップ・詳細画面のカテゴリバッジを表示言語に追従
- ✅ 言語切替を共通ウィジェット化（`widgets/language_segmented_control.dart`）し、
  設定画面もダイアログ+Radio方式から同スタイルに統一
  - 副次効果: deprecated警告（Radio groupValue/onChanged）が全解消 → **Flutter Analyze: No issues found!**

#### 現場の漢字 機能強化 ✅（2026-06-07追加）
- ✅ 苦手×クイズ連携
  - クイズ解説カードに⭐苦手登録トグル
  - 結果画面に「間違えた語」一覧（⭐でその場で苦手登録）
  - 苦手クイズモード（苦手漢字のみ出題、読み/意味ミックス、メニューに追加）
- ✅ 漢字語を60→100語に拡充（各カテゴリ20語、kanji.json data_version: 2）
  - 消火器・感電注意・自動/手動・工具・図面・夜勤・朝礼・健康診断など
- ✅ 検索画面でフレーズ+漢字語を横断検索
  - セクション分け表示、漢字語タップで標識スタイルの詳細ボトムシート
- ❌ ホームの「今日の標識」ミニプレビューは方針変更により削除

#### アプリ内課金 基盤（フェーズ0） ✅（2026-06-07追加）
詳細仕様: `docs/monetization.md`
- ✅ 収益化方針決定: コンテンツパック買い切り（既存コンテンツは全部無料維持）
- ✅ in_app_purchase導入、DB v5→v6（pack_id列 + purchasesテーブル）
- ✅ Phrase/QuizモデルにpackId（null=無料）、QuizRepositoryにdata_version差分同期
- ✅ PurchaseService / PurchaseRepository / EntitlementNotifier（オフライン解錠対応）
- ✅ ストア画面（商品一覧・購入・復元）、設定画面に導線、LockedContentBanner
- ✅ 法的ページ更新（利用規約 第8条/Pasal 8 追加、プライバシーポリシー第5項改訂）
- ✅ ユニットテスト追加（購入ステータス処理・モデル・DBマイグレーション、計68テスト）
- ⏳ フェーズ1: JLPT N3/N2対策パックのコンテンツ制作、App Store Connect商品登録

---

## ❌ 削除された機能

以下の機能は、MVP（Minimum Viable Product）のスコープ外として削除されました：

1. **録音・発音練習機能**
   - 理由: 実装の複雑さとMVPでは不要

2. **学習履歴トラッキング**
   - 理由: シンプルさを優先、将来的な拡張機能として保留

3. **連続学習日数（ストリーク）機能**
   - 理由: 学習履歴機能の削除に伴い不要

4. **音声速度調整機能**
   - 理由: TTS機能では速度調整は実装しない方針

5. **データリセット機能**
   - 理由: 学習履歴機能がないため不要

---

### フェーズ4: テスト・リリース準備 (Week 9-11) - 25% 完了

#### Week 9: テスト実装（基礎） ✅
- ✅ テスト環境のセットアップ
  - テストディレクトリ構造の作成
  - テストパッケージの設定
- ✅ データモデルのユニットテスト（14テスト）
  - Phraseモデル（8テスト）
  - Categoryモデル（7テスト）
  - すべてのテストがパス
- ⏳ リポジトリのユニットテスト（今後追加予定）
- ⏳ Providerのテスト（今後追加予定）
- ⏳ ウィジェットテスト（今後追加予定）

#### Week 11: リリース準備（アイコン） ✅
- ✅ アプリアイコン設定
  - assets/images/app_icon.png（1379KB）
  - flutter_launcher_icons による iOS アイコン生成
- ❌ スプラッシュ画面実装（削除）
  - 理由: デザインが合わないため実装しない
  - デフォルトの白い画面を使用

## 🔄 未実装の機能

### Week 9の残タスク
- ⏳ リポジトリのユニットテスト
- ⏳ Providerのテスト
- ⏳ ウィジェットテスト実装
- ⏳ 統合テスト実装

### Week 10のタスク
- ⏳ UI/UX改善
- ⏳ アニメーション追加
- ⏳ アクセシビリティ改善

### Week 11の残タスク
- ⏳ App Store / Google Play 準備
  - スクリーンショット作成（7枚以上）
  - アプリ説明文の最終確認
  - ストア申請資料の準備
- ⏳ リリースビルド作成
  - Android APK/AAB
  - iOS IPA
- ⏳ ベータテスト（TestFlight / Internal Testing）

### 削除された機能
- ❌ スプラッシュ画面（Week 11）
  - 理由: デザインが合わないため実装しない

---

## 📊 進捗状況

```
全体進捗: ██████████████░ 91%

フェーズ1（Week 1-2）:  ████████████ 100% ✅
フェーズ2（Week 3-6）:  ████████████ 100% ✅
フェーズ3（Week 7-8）:  ████████████ 100% ✅
フェーズ4（Week 9-11）: ███░░░░░░░░░  25% 🔄
```

---

## 🎯 次のステップ（優先順位順）

### 高優先度
1. **Week 9: テスト実装の継続**
   - リポジトリのユニットテスト
   - Providerのテスト
   - ウィジェットテスト（主要画面）
   - 統合テスト（主要フロー）

2. **Week 11: ストア申請準備**
   - スクリーンショット作成（7枚以上）
   - アプリ説明文の最終確認
   - リリースビルド作成（APK/AAB, IPA）
   - ベータテスト実施

### 中優先度
3. **Week 10: UI/UX改善**
   - アニメーション追加
   - アクセシビリティ改善
   - デザインレビュー

---

## 📁 ファイル構成

### 実装済みファイル

```
lib/
├── main.dart                                    ✅
├── l10n/
│   ├── app_localizations.dart                   ✅
│   ├── app_localizations_ja.dart                ✅
│   ├── app_localizations_id.dart                ✅
│   ├── app_ja.arb                               ✅
│   └── app_id.arb                               ✅
├── data/
│   ├── models/
│   │   ├── phrase.dart                          ✅
│   │   ├── category.dart                        ✅
│   │   └── quiz.dart                            ✅
│   ├── datasources/
│   │   └── local/
│   │       └── database_helper.dart             ✅
│   └── repositories/
│       ├── phrase_repository.dart               ✅
│       └── quiz_repository.dart                 ✅
├── presentation/
│   ├── providers/
│   │   ├── phrase_provider.dart                 ✅
│   │   ├── quiz_provider.dart                   ✅
│   │   └── settings_provider.dart               ✅
│   ├── services/
│   │   └── tts_service.dart                     ✅（Week 8で改善）
│   ├── widgets/
│   │   ├── error_view.dart                      ✅（Week 8で新規作成）
│   │   └── loading_view.dart                    ✅（Week 8で新規作成）
│   └── screens/
│       ├── home/
│       │   └── home_screen.dart                 ✅
│       ├── phrases/
│       │   └── phrase_list_screen.dart          ✅
│       ├── phrase_detail/
│       │   └── phrase_detail_screen.dart        ✅
│       ├── favorites/
│       │   └── favorites_screen.dart            ✅
│       ├── search/
│       │   └── search_screen.dart               ✅
│       ├── quiz/
│       │   └── quiz_screen.dart                 ✅
│       ├── settings/
│       │   └── settings_screen.dart             ✅
│       └── legal/
│           ├── terms_of_service_screen.dart     ✅
│           ├── privacy_policy_screen.dart       ✅
│           └── contact_screen.dart              ✅
└── assets/
    └── data/
        ├── phrases.json                         ✅
        └── quiz_data.json                       ✅

### テストファイル

```
test/
├── unit/
│   ├── models/
│   │   ├── phrase_test.dart                     ✅（Week 9で新規作成・8テスト）
│   │   └── category_test.dart                   ✅（Week 9で新規作成・7テスト）
│   ├── repositories/                            ⏳（今後追加予定）
│   └── providers/                               ⏳（今後追加予定）
└── widget/                                      ⏳（今後追加予定）
```

---

## 🔍 コード品質

### 現在の状態
- **Flutter Analyze: No issues found!** ✅
- 本体の`lib/`フォルダ: エラーなし ✅
- コーディング規約: 準拠 ✅
- Clean Architecture: 準拠 ✅

### 完了した改善項目
1. ~~`print`文を`debugPrint`に置き換え~~ ✅
2. ~~`use_build_context_synchronously`警告の修正~~ ✅
3. エラーハンドリングの強化 ✅
4. 共通UIコンポーネントの作成 ✅

---

## 📝 ドキュメント

### 完成したドキュメント
- ✅ `docs/readme.md` - 要件定義書
- ✅ `docs/data-model.md` - データモデル仕様
- ✅ `docs/ui-design.md` - UI/UX設計
- ✅ `docs/tech-stack.md` - 技術スタック
- ✅ `docs/project-structure.md` - プロジェクト構造
- ✅ `docs/roadmap.md` - 開発ロードマップ
- ✅ `CLAUDE.md` - Claude Code用ガイダンス

### 追加作成したドキュメント
- ✅ サポートページコンテンツ（日本語・インドネシア語）
- ✅ アプリ説明文（英語）
- ✅ 実装状況レポート（本ドキュメント）

---

## 🎉 主な成果

1. **329フレーズを収録**
   - N5: 72個、N4: 106個、N3: 102個、N2: 49個
   - カテゴリ別分類（あいさつ、安全、作業、日常会話、緊急）

2. **完全な多言語対応**
   - 日本語・インドネシア語の完全対応
   - UI、データ、法的ページすべて2言語対応

3. **オフライン完全対応**
   - インターネット接続不要
   - すべてのデータをローカルDB保存

4. **Clean Architectureの採用**
   - 保守性の高いコード構造
   - テスト容易性の確保

5. **包括的な法的対応**
   - 利用規約、プライバシーポリシー、お問い合わせページ
   - App Store / Google Play審査に対応

---

**次回の作業**: Week 8のタスク（エラーハンドリング・オフライン対応確認）からスタート
