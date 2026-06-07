// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '現場にほんご';

  @override
  String get navHome => 'ホーム';

  @override
  String get navPhrases => 'フレーズ一覧';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navSettings => '設定';

  @override
  String get homeGreetingMorning => 'おはようございます！今日も安全第一で';

  @override
  String get homeGreetingDay => 'こんにちは！';

  @override
  String get homeGreetingAfternoon => 'こんにちは！もうひとがんばり';

  @override
  String get homeGreetingNight => 'お疲れさまでした！ゆっくり休んでください';

  @override
  String get stopAudio => '再生を停止';

  @override
  String get homeGreeting => 'おはようございます！';

  @override
  String get homeDailyPhrases => '📅 今日の3フレーズ';

  @override
  String get phraseDetail => 'フレーズ詳細';

  @override
  String get playAudio => '音声を聞く';

  @override
  String get playing => '再生中...';

  @override
  String get labelJapanese => '日本語';

  @override
  String get labelRomaji => 'ローマ字';

  @override
  String get labelIndonesian => 'Bahasa Indonesia';

  @override
  String get favoriteAdded => 'お気に入りに追加しました';

  @override
  String get favoriteRemoved => 'お気に入りから削除しました';

  @override
  String get noFavorites => 'お気に入りがありません';

  @override
  String get noPhrases => 'フレーズがありません';

  @override
  String get searchHint => 'フレーズを検索...';

  @override
  String get searchTitle => '検索';

  @override
  String get allLevels => 'すべて';

  @override
  String get allCategories => 'すべて';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsDisplay => '表示設定';

  @override
  String get settingsDarkMode => 'ダークモード';

  @override
  String get settingsDarkModeOn => 'オン';

  @override
  String get settingsDarkModeOff => 'オフ';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageJa => '日本語';

  @override
  String get settingsLanguageId => 'Bahasa Indonesia';

  @override
  String get settingsAppInfo => 'アプリ情報';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsPhraseCount => 'フレーズ数';

  @override
  String get settingsDeveloper => '開発者';

  @override
  String get settingsOther => 'その他';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get aboutDescription1 => '日本の工場で働くインドネシア人技能実習生向けの日本語学習アプリです。';

  @override
  String get aboutDescription2 => '現場で必要な日本語フレーズを音声で学習できます。';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get loading => '読み込み中...';

  @override
  String favoritesCount(int count) {
    return '$count件のお気に入り';
  }

  @override
  String get noFavoritesYet => 'お気に入りはまだありません';

  @override
  String get addFavoritesHint => 'フレーズ詳細画面で\nハートアイコンをタップして\nお気に入りに追加しましょう';

  @override
  String searchResults(int count) {
    return '$count件の検索結果';
  }

  @override
  String get noSearchResults => '検索結果がありません';

  @override
  String get quizTitle => 'N3演習問題';

  @override
  String get quizCardTitle => 'N3演習問題に挑戦';

  @override
  String get quizCardDescription => '文法と語彙を学ぼう！';

  @override
  String get quizAnswer => '回答する';

  @override
  String get quizNext => '次へ';

  @override
  String get quizViewResults => '結果を見る';

  @override
  String get quizExplanation => '解説';

  @override
  String get quizResultTitle => '結果';

  @override
  String get quizCompleted => 'おつかれさまでした！';

  @override
  String get quizYourScore => 'あなたのスコア';

  @override
  String get quizBackToHome => 'ホームに戻る';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get contact => 'お問い合わせ';

  @override
  String get termsTitle => '利用規約';

  @override
  String get privacyTitle => 'プライバシーポリシー';

  @override
  String get contactTitle => 'お問い合わせ';

  @override
  String get contactEmail => 'メールアドレス';

  @override
  String get contactMessage => '以下のメールアドレスまでお問い合わせください。';

  @override
  String get copyEmail => 'メールアドレスをコピー';

  @override
  String get emailCopied => 'メールアドレスをコピーしました';

  @override
  String get lastUpdated => '最終更新日';

  @override
  String get quizTitleN2 => 'N2演習問題';

  @override
  String get quizCardTitleN2 => 'N2演習問題に挑戦';

  @override
  String get quizCardDescriptionN2 => '対策パックでN2の文法・語彙を学ぼう';

  @override
  String get storeTitle => 'コンテンツパック';

  @override
  String get storeDescription => '買い切りで追加コンテンツを解錠できます。一度購入すればずっと使えます。';

  @override
  String get storeBuy => '購入';

  @override
  String get storePurchased => '購入済み';

  @override
  String get storeRestore => '購入を復元';

  @override
  String get storeRestoreStarted => '購入の復元を確認しています...';

  @override
  String get storeUnavailable => 'ストアに接続できません。インターネット接続を確認してください。';

  @override
  String get storeNoProducts => '現在販売中のパックはありません。';

  @override
  String get storePending => 'ストアの承認待ちです。承認されると自動的に解錠されます。';

  @override
  String get storeError => '購入処理でエラーが発生しました';

  @override
  String get lockedContentMessage => 'このコンテンツはパック購入で解錠できます';

  @override
  String lockedPreviewMore(int count) {
    return '続きの$count件はパック購入で解錠できます';
  }

  @override
  String get lockedContentUnlock => '解錠する';

  @override
  String get kanjiCardTitle => '現場の漢字';

  @override
  String get kanjiCardDescription => '工場でよく見る漢字を学ぼう';

  @override
  String get kanjiMenuCards => '漢字カード';

  @override
  String get kanjiMenuCardsDesc => 'カードをめくって覚える';

  @override
  String get kanjiMenuReadingQuiz => '読みクイズ';

  @override
  String get kanjiMenuReadingQuizDesc => '正しい読み方を選ぶ';

  @override
  String get kanjiMenuMeaningQuiz => '意味クイズ';

  @override
  String get kanjiMenuMeaningQuizDesc => '正しい意味を選ぶ';

  @override
  String get kanjiMenuFavorites => '苦手な漢字';

  @override
  String get kanjiMenuFavoritesDesc => '保存した漢字を復習する';

  @override
  String get kanjiFavoritesQuiz => '苦手クイズ';

  @override
  String get kanjiFavoritesQuizDesc => '苦手な漢字だけで腕試し';

  @override
  String get kanjiWrongAnswers => '間違えた語';

  @override
  String get kanjiMarkDifficult => '苦手に登録';

  @override
  String get kanjiNoFavorites => '苦手な漢字はまだありません';

  @override
  String get kanjiNoWords => '漢字データがありません';

  @override
  String get kanjiTapToFlip => 'タップして答えを見る';

  @override
  String get kanjiQuizQuestionReading => 'この漢字の読み方は?';

  @override
  String get kanjiQuizQuestionMeaning => 'この漢字の意味は?';

  @override
  String get kanjiWhereToSee => 'どこで見る?';

  @override
  String get allCategoriesKanji => 'すべて';
}
