import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('ja')
  ];

  /// アプリケーションのタイトル
  ///
  /// In ja, this message translates to:
  /// **'現場にほんご'**
  String get appTitle;

  /// ナビゲーション: ホーム
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get navHome;

  /// ナビゲーション: フレーズ一覧
  ///
  /// In ja, this message translates to:
  /// **'フレーズ一覧'**
  String get navPhrases;

  /// ナビゲーション: お気に入り
  ///
  /// In ja, this message translates to:
  /// **'お気に入り'**
  String get navFavorites;

  /// ナビゲーション: 設定
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// ホーム画面のあいさつ（朝5-10時）
  ///
  /// In ja, this message translates to:
  /// **'おはようございます！今日も安全第一で'**
  String get homeGreetingMorning;

  /// ホーム画面のあいさつ（昼10-15時）
  ///
  /// In ja, this message translates to:
  /// **'こんにちは！'**
  String get homeGreetingDay;

  /// ホーム画面のあいさつ（夕方15-18時）
  ///
  /// In ja, this message translates to:
  /// **'こんにちは！もうひとがんばり'**
  String get homeGreetingAfternoon;

  /// ホーム画面のあいさつ（夜18時以降・早朝）
  ///
  /// In ja, this message translates to:
  /// **'お疲れさまでした！ゆっくり休んでください'**
  String get homeGreetingNight;

  /// 音声停止ボタンのツールチップ
  ///
  /// In ja, this message translates to:
  /// **'再生を停止'**
  String get stopAudio;

  /// ホーム画面の挨拶
  ///
  /// In ja, this message translates to:
  /// **'おはようございます！'**
  String get homeGreeting;

  /// 今日のフレーズセクションタイトル
  ///
  /// In ja, this message translates to:
  /// **'📅 今日の3フレーズ'**
  String get homeDailyPhrases;

  /// フレーズ詳細画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'フレーズ詳細'**
  String get phraseDetail;

  /// 音声再生ボタン
  ///
  /// In ja, this message translates to:
  /// **'音声を聞く'**
  String get playAudio;

  /// 再生中の状態
  ///
  /// In ja, this message translates to:
  /// **'再生中...'**
  String get playing;

  /// 日本語ラベル
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get labelJapanese;

  /// ローマ字ラベル
  ///
  /// In ja, this message translates to:
  /// **'ローマ字'**
  String get labelRomaji;

  /// インドネシア語ラベル
  ///
  /// In ja, this message translates to:
  /// **'Bahasa Indonesia'**
  String get labelIndonesian;

  /// お気に入り追加メッセージ
  ///
  /// In ja, this message translates to:
  /// **'お気に入りに追加しました'**
  String get favoriteAdded;

  /// お気に入り削除メッセージ
  ///
  /// In ja, this message translates to:
  /// **'お気に入りから削除しました'**
  String get favoriteRemoved;

  /// お気に入りが空の時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'お気に入りがありません'**
  String get noFavorites;

  /// フレーズが見つからない時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'フレーズがありません'**
  String get noPhrases;

  /// 検索欄のヒント
  ///
  /// In ja, this message translates to:
  /// **'フレーズを検索...'**
  String get searchHint;

  /// 検索画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get searchTitle;

  /// すべてのレベル
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get allLevels;

  /// すべてのカテゴリ
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get allCategories;

  /// 設定画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// 表示設定セクション
  ///
  /// In ja, this message translates to:
  /// **'表示設定'**
  String get settingsDisplay;

  /// ダークモード設定
  ///
  /// In ja, this message translates to:
  /// **'ダークモード'**
  String get settingsDarkMode;

  /// ダークモードオン
  ///
  /// In ja, this message translates to:
  /// **'オン'**
  String get settingsDarkModeOn;

  /// ダークモードオフ
  ///
  /// In ja, this message translates to:
  /// **'オフ'**
  String get settingsDarkModeOff;

  /// 言語設定
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get settingsLanguage;

  /// 日本語
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get settingsLanguageJa;

  /// インドネシア語
  ///
  /// In ja, this message translates to:
  /// **'Bahasa Indonesia'**
  String get settingsLanguageId;

  /// アプリ情報セクション
  ///
  /// In ja, this message translates to:
  /// **'アプリ情報'**
  String get settingsAppInfo;

  /// バージョン
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get settingsVersion;

  /// フレーズ数
  ///
  /// In ja, this message translates to:
  /// **'フレーズ数'**
  String get settingsPhraseCount;

  /// 開発者
  ///
  /// In ja, this message translates to:
  /// **'開発者'**
  String get settingsDeveloper;

  /// その他セクション
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get settingsOther;

  /// アプリについて
  ///
  /// In ja, this message translates to:
  /// **'アプリについて'**
  String get settingsAbout;

  /// アプリ説明1
  ///
  /// In ja, this message translates to:
  /// **'日本の工場で働くインドネシア人技能実習生向けの日本語学習アプリです。'**
  String get aboutDescription1;

  /// アプリ説明2
  ///
  /// In ja, this message translates to:
  /// **'現場で必要な日本語フレーズを音声で学習できます。'**
  String get aboutDescription2;

  /// エラーメッセージ
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました'**
  String get errorOccurred;

  /// 読み込み中
  ///
  /// In ja, this message translates to:
  /// **'読み込み中...'**
  String get loading;

  /// お気に入りの件数
  ///
  /// In ja, this message translates to:
  /// **'{count}件のお気に入り'**
  String favoritesCount(int count);

  /// お気に入りが空の時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'お気に入りはまだありません'**
  String get noFavoritesYet;

  /// お気に入り追加のヒント
  ///
  /// In ja, this message translates to:
  /// **'フレーズ詳細画面で\nハートアイコンをタップして\nお気に入りに追加しましょう'**
  String get addFavoritesHint;

  /// 検索結果の件数
  ///
  /// In ja, this message translates to:
  /// **'{count}件の検索結果'**
  String searchResults(int count);

  /// 検索結果が見つからない時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'検索結果がありません'**
  String get noSearchResults;

  /// クイズ画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'N3演習問題'**
  String get quizTitle;

  /// ホーム画面のクイズカードタイトル
  ///
  /// In ja, this message translates to:
  /// **'N3演習問題に挑戦'**
  String get quizCardTitle;

  /// ホーム画面のクイズカード説明
  ///
  /// In ja, this message translates to:
  /// **'文法と語彙を学ぼう！'**
  String get quizCardDescription;

  /// 回答ボタン
  ///
  /// In ja, this message translates to:
  /// **'回答する'**
  String get quizAnswer;

  /// 次へボタン
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get quizNext;

  /// 結果を見るボタン
  ///
  /// In ja, this message translates to:
  /// **'結果を見る'**
  String get quizViewResults;

  /// 解説セクション
  ///
  /// In ja, this message translates to:
  /// **'解説'**
  String get quizExplanation;

  /// 結果画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'結果'**
  String get quizResultTitle;

  /// クイズ完了メッセージ
  ///
  /// In ja, this message translates to:
  /// **'おつかれさまでした！'**
  String get quizCompleted;

  /// あなたのスコア
  ///
  /// In ja, this message translates to:
  /// **'あなたのスコア'**
  String get quizYourScore;

  /// ホームに戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'ホームに戻る'**
  String get quizBackToHome;

  /// 利用規約
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfService;

  /// プライバシーポリシー
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// お問い合わせ
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get contact;

  /// 利用規約画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsTitle;

  /// プライバシーポリシー画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyTitle;

  /// お問い合わせ画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get contactTitle;

  /// メールアドレスラベル
  ///
  /// In ja, this message translates to:
  /// **'メールアドレス'**
  String get contactEmail;

  /// お問い合わせメッセージ
  ///
  /// In ja, this message translates to:
  /// **'以下のメールアドレスまでお問い合わせください。'**
  String get contactMessage;

  /// メールアドレスをコピーボタン
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスをコピー'**
  String get copyEmail;

  /// メールアドレスコピー完了メッセージ
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスをコピーしました'**
  String get emailCopied;

  /// 最終更新日
  ///
  /// In ja, this message translates to:
  /// **'最終更新日'**
  String get lastUpdated;

  /// ボトムナビ: 漢字学習タブ
  ///
  /// In ja, this message translates to:
  /// **'漢字学習'**
  String get navKanji;

  /// ボトムナビ: 演習問題タブ
  ///
  /// In ja, this message translates to:
  /// **'演習問題'**
  String get navQuiz;

  /// ホームの漢字学習ブロックタイトル
  ///
  /// In ja, this message translates to:
  /// **'漢字学習'**
  String get homeKanjiBlockTitle;

  /// ホームの漢字学習ブロック説明
  ///
  /// In ja, this message translates to:
  /// **'現場の漢字をカードとクイズで覚えよう'**
  String get homeKanjiBlockDesc;

  /// ホームのJLPT演習問題ブロックタイトル
  ///
  /// In ja, this message translates to:
  /// **'JLPT演習問題'**
  String get homeJlptBlockTitle;

  /// ホームのJLPT演習問題ブロック説明
  ///
  /// In ja, this message translates to:
  /// **'N3・N2の文法・語彙・漢字読み'**
  String get homeJlptBlockDesc;

  /// 漢字辞書画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'漢字辞書'**
  String get kanjiDictTitle;

  /// 漢字ハブの辞書メニュー説明
  ///
  /// In ja, this message translates to:
  /// **'収録語と漢字をまとめて引ける'**
  String get kanjiDictMenuDesc;

  /// 漢字辞書の検索ヒント
  ///
  /// In ja, this message translates to:
  /// **'語・読み・意味で検索'**
  String get kanjiDictSearchHint;

  /// 漢字辞書の並び順: 読み順
  ///
  /// In ja, this message translates to:
  /// **'あいうえお順'**
  String get kanjiDictSortReading;

  /// 漢字辞書の並び順: カテゴリ順
  ///
  /// In ja, this message translates to:
  /// **'カテゴリ順'**
  String get kanjiDictSortCategory;

  /// 語詳細の構成漢字セクション
  ///
  /// In ja, this message translates to:
  /// **'構成漢字'**
  String get kanjiDictChars;

  /// 構成漢字がタップできることのヒント
  ///
  /// In ja, this message translates to:
  /// **'タップで読み方・意味を表示'**
  String get kanjiDictTapHint;

  /// 未購入時の辞書機能紹介タイトル
  ///
  /// In ja, this message translates to:
  /// **'漢字辞書パックで解放される機能'**
  String get kanjiDictLockedTitle;

  /// 未購入時の辞書機能紹介文
  ///
  /// In ja, this message translates to:
  /// **'この語に使われている漢字を1文字ずつ辞書で引けるようになります。\n・音読み・訓読み\n・漢字の意味（インドネシア語）\n・この漢字を使うほかの語（逆引き）'**
  String get kanjiDictLockedDesc;

  /// 単漢字詳細の音読みラベル
  ///
  /// In ja, this message translates to:
  /// **'音読み'**
  String get kanjiDictOnYomi;

  /// 単漢字詳細の訓読みラベル
  ///
  /// In ja, this message translates to:
  /// **'訓読み'**
  String get kanjiDictKunYomi;

  /// 単漢字詳細の逆引きセクション
  ///
  /// In ja, this message translates to:
  /// **'この漢字を使う語'**
  String get kanjiDictRelated;

  /// 漢字ハブのカテゴリー別クイズセクション見出し
  ///
  /// In ja, this message translates to:
  /// **'カテゴリー別クイズ'**
  String get kanjiCategoryQuizSection;

  /// JLPT演習問題の分野: 文法
  ///
  /// In ja, this message translates to:
  /// **'文法'**
  String get quizCategoryGrammar;

  /// JLPT演習問題の分野: 語彙
  ///
  /// In ja, this message translates to:
  /// **'語彙'**
  String get quizCategoryVocab;

  /// JLPT演習問題の分野: 漢字読み
  ///
  /// In ja, this message translates to:
  /// **'漢字読み'**
  String get quizCategoryKanjiReading;

  /// N2クイズ画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'N2演習問題'**
  String get quizTitleN2;

  /// ホーム画面のN2クイズカードタイトル
  ///
  /// In ja, this message translates to:
  /// **'N2演習問題に挑戦'**
  String get quizCardTitleN2;

  /// ホーム画面のN2クイズカード説明
  ///
  /// In ja, this message translates to:
  /// **'対策パックでN2の文法・語彙を学ぼう'**
  String get quizCardDescriptionN2;

  /// ストア画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'コンテンツパック'**
  String get storeTitle;

  /// ストア画面の説明文
  ///
  /// In ja, this message translates to:
  /// **'買い切りで追加コンテンツを解錠できます。一度購入すればずっと使えます。'**
  String get storeDescription;

  /// 購入ボタン
  ///
  /// In ja, this message translates to:
  /// **'購入'**
  String get storeBuy;

  /// 購入済みバッジ
  ///
  /// In ja, this message translates to:
  /// **'購入済み'**
  String get storePurchased;

  /// 購入復元ボタン
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get storeRestore;

  /// 復元開始時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'購入の復元を確認しています...'**
  String get storeRestoreStarted;

  /// ストア未接続時のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'ストアに接続できません。インターネット接続を確認してください。'**
  String get storeUnavailable;

  /// 商品がない場合のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'現在販売中のパックはありません。'**
  String get storeNoProducts;

  /// 購入承認待ちのメッセージ
  ///
  /// In ja, this message translates to:
  /// **'ストアの承認待ちです。承認されると自動的に解錠されます。'**
  String get storePending;

  /// 購入エラーのメッセージ
  ///
  /// In ja, this message translates to:
  /// **'購入処理でエラーが発生しました'**
  String get storeError;

  /// ロックされたコンテンツの案内
  ///
  /// In ja, this message translates to:
  /// **'このコンテンツはパック購入で解錠できます'**
  String get lockedContentMessage;

  /// ロック中カテゴリのプレビュー下の案内
  ///
  /// In ja, this message translates to:
  /// **'続きの{count}件はパック購入で解錠できます'**
  String lockedPreviewMore(int count);

  /// ロック解除への導線ボタン
  ///
  /// In ja, this message translates to:
  /// **'解錠する'**
  String get lockedContentUnlock;

  /// ホーム画面の漢字学習カードタイトル
  ///
  /// In ja, this message translates to:
  /// **'現場の漢字'**
  String get kanjiCardTitle;

  /// ホーム画面の漢字学習カード説明
  ///
  /// In ja, this message translates to:
  /// **'工場でよく見る漢字を学ぼう'**
  String get kanjiCardDescription;

  /// 漢字カード学習メニュー
  ///
  /// In ja, this message translates to:
  /// **'漢字カード'**
  String get kanjiMenuCards;

  /// 漢字カード学習メニューの説明
  ///
  /// In ja, this message translates to:
  /// **'カードをめくって覚える'**
  String get kanjiMenuCardsDesc;

  /// 読みクイズメニュー
  ///
  /// In ja, this message translates to:
  /// **'読みクイズ'**
  String get kanjiMenuReadingQuiz;

  /// 読みクイズメニューの説明
  ///
  /// In ja, this message translates to:
  /// **'正しい読み方を選ぶ'**
  String get kanjiMenuReadingQuizDesc;

  /// 意味クイズメニュー
  ///
  /// In ja, this message translates to:
  /// **'意味クイズ'**
  String get kanjiMenuMeaningQuiz;

  /// 意味クイズメニューの説明
  ///
  /// In ja, this message translates to:
  /// **'正しい意味を選ぶ'**
  String get kanjiMenuMeaningQuizDesc;

  /// 苦手漢字メニュー
  ///
  /// In ja, this message translates to:
  /// **'苦手な漢字'**
  String get kanjiMenuFavorites;

  /// 苦手漢字メニューの説明
  ///
  /// In ja, this message translates to:
  /// **'保存した漢字を復習する'**
  String get kanjiMenuFavoritesDesc;

  /// 苦手漢字クイズのタイトル
  ///
  /// In ja, this message translates to:
  /// **'苦手クイズ'**
  String get kanjiFavoritesQuiz;

  /// 苦手漢字クイズメニューの説明
  ///
  /// In ja, this message translates to:
  /// **'苦手な漢字だけで腕試し'**
  String get kanjiFavoritesQuizDesc;

  /// クイズ結果画面の間違えた語セクション
  ///
  /// In ja, this message translates to:
  /// **'間違えた語'**
  String get kanjiWrongAnswers;

  /// 苦手登録トグルのラベル
  ///
  /// In ja, this message translates to:
  /// **'苦手に登録'**
  String get kanjiMarkDifficult;

  /// 苦手漢字が空の場合のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'苦手な漢字はまだありません'**
  String get kanjiNoFavorites;

  /// 漢字データが空の場合のメッセージ
  ///
  /// In ja, this message translates to:
  /// **'漢字データがありません'**
  String get kanjiNoWords;

  /// 漢字カードの操作ヒント
  ///
  /// In ja, this message translates to:
  /// **'タップして答えを見る'**
  String get kanjiTapToFlip;

  /// 読みクイズの問題文
  ///
  /// In ja, this message translates to:
  /// **'この漢字の読み方は?'**
  String get kanjiQuizQuestionReading;

  /// 意味クイズの問題文
  ///
  /// In ja, this message translates to:
  /// **'この漢字の意味は?'**
  String get kanjiQuizQuestionMeaning;

  /// 漢字カードの使用場面ラベル
  ///
  /// In ja, this message translates to:
  /// **'どこで見る?'**
  String get kanjiWhereToSee;

  /// 漢字カテゴリの「すべて」チップ
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get allCategoriesKanji;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['id', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
