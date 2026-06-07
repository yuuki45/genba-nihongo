import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/kanji_word.dart';
import '../../data/repositories/kanji_repository.dart';
import 'phrase_provider.dart' show searchQueryProvider;

/// KanjiRepositoryのProvider
final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  return KanjiRepository();
});

/// すべての漢字語を取得するProvider
/// キャッシュを保持してパフォーマンスを向上
final allKanjiWordsProvider = FutureProvider<List<KanjiWord>>((ref) async {
  // データはめったに変更されないためキャッシュを保持
  ref.keepAlive();
  final repository = ref.watch(kanjiRepositoryProvider);
  return await repository.getAllKanjiWords();
});

/// 選択中の漢字カテゴリキーを管理するProvider（nullは「すべて」）
final selectedKanjiCategoryProvider = StateProvider<String?>((ref) => null);

/// カテゴリでフィルタリングされた漢字語を取得するProvider
final filteredKanjiWordsProvider = FutureProvider<List<KanjiWord>>((ref) async {
  final repository = ref.watch(kanjiRepositoryProvider);
  final categoryKey = ref.watch(selectedKanjiCategoryProvider);

  if (categoryKey == null) {
    return await repository.getAllKanjiWords();
  }
  return await repository.getKanjiWordsByCategory(categoryKey);
});

/// 苦手漢字を取得するProvider
final favoriteKanjiWordsProvider = FutureProvider<List<KanjiWord>>((ref) async {
  final repository = ref.watch(kanjiRepositoryProvider);
  return await repository.getFavoriteKanjiWords();
});

/// 漢字語の検索結果を取得するProvider
///
/// フレーズ検索と同じ検索クエリ（searchQueryProvider）を共有する。
final kanjiSearchResultsProvider =
    FutureProvider.autoDispose<List<KanjiWord>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(kanjiRepositoryProvider);

  if (query.isEmpty) {
    return [];
  }

  return await repository.searchKanjiWords(query);
});

/// 苦手漢字の登録状態を管理するProvider
final kanjiFavoriteStateProvider =
    StateNotifierProvider.family<KanjiFavoriteStateNotifier, bool, int>(
  (ref, kanjiWordId) => KanjiFavoriteStateNotifier(ref, kanjiWordId),
);

/// 苦手漢字の状態管理クラス
class KanjiFavoriteStateNotifier extends StateNotifier<bool> {
  final Ref ref;
  final int kanjiWordId;

  KanjiFavoriteStateNotifier(this.ref, this.kanjiWordId) : super(false) {
    _initialize();
  }

  Future<void> _initialize() async {
    final repository = ref.read(kanjiRepositoryProvider);
    state = await repository.isFavorite(kanjiWordId);
  }

  Future<void> toggle() async {
    final repository = ref.read(kanjiRepositoryProvider);

    if (state) {
      await repository.removeFavorite(kanjiWordId);
      state = false;
    } else {
      await repository.addFavorite(kanjiWordId);
      state = true;
    }

    // 苦手漢字一覧を更新
    ref.invalidate(favoriteKanjiWordsProvider);
  }
}

/// 漢字クイズのモード
enum KanjiQuizMode {
  reading, // 読みクイズ（語 → 読みを選ぶ）
  meaning, // 意味クイズ（語 → 意味を選ぶ）
}

/// 漢字クイズの設定（出題モードと出題範囲）
///
/// [mode] がnullの場合は問題ごとに読み/意味をランダムに混ぜる。
/// [favoritesOnly] がtrueの場合は苦手漢字のみから出題する。
typedef KanjiQuizConfig = ({KanjiQuizMode? mode, bool favoritesOnly});

/// 漢字クイズの1問
///
/// 静的なクイズデータは持たず、漢字語データから動的に生成する。
class KanjiQuizQuestion {
  final KanjiWord word;
  final KanjiQuizMode mode;
  final List<String> options;
  final int correctIndex;

  KanjiQuizQuestion({
    required this.word,
    required this.mode,
    required this.options,
    required this.correctIndex,
  });
}

/// 漢字クイズの問題数
const int kanjiQuizQuestionCount = 10;

/// 漢字クイズの選択肢数
const int kanjiQuizOptionCount = 4;

/// 漢字クイズの問題を動的に生成するProvider
///
/// 出題語をランダムに選び、誤答は他の語の読み（または意味）から抽出する。
/// autoDisposeのため、画面を開き直すたびに新しい問題が生成される。
final kanjiQuizQuestionsProvider = FutureProvider.autoDispose
    .family<List<KanjiQuizQuestion>, KanjiQuizConfig>((ref, config) async {
  final repository = ref.watch(kanjiRepositoryProvider);
  final allWords = await repository.getAllKanjiWords();

  // 苦手モードでは出題語を苦手漢字に限定する（誤答候補は全語から選ぶ）
  final questionWords = config.favoritesOnly
      ? await repository.getFavoriteKanjiWords()
      : allWords;

  return generateKanjiQuizQuestions(
    allWords,
    config.mode,
    questionWords: questionWords,
  );
});

/// 漢字語リストからクイズ問題を生成する
///
/// [pool] は誤答候補の母集団、[questionWords] は出題語（省略時はpool全体）。
/// [mode] がnullの場合は問題ごとに読み/意味をランダムに切り替える。
/// テスト容易性のためProviderから分離した純粋関数。
List<KanjiQuizQuestion> generateKanjiQuizQuestions(
  List<KanjiWord> pool,
  KanjiQuizMode? mode, {
  List<KanjiWord>? questionWords,
  Random? random,
}) {
  final rng = random ?? Random();

  final candidates = (questionWords ?? pool).toList()..shuffle(rng);
  final selected = candidates.take(kanjiQuizQuestionCount).toList();

  return selected.map((word) {
    // モード未指定（ミックス）の場合は問題ごとにランダムに決める
    final questionMode = mode ??
        (rng.nextBool() ? KanjiQuizMode.reading : KanjiQuizMode.meaning);

    // 選択肢を取り出すヘルパー（モードによって読み/意味を切り替え）
    String optionOf(KanjiWord w) =>
        questionMode == KanjiQuizMode.reading ? w.reading : w.indonesian;

    // 誤答候補: 正答と同じ選択肢になる語（同音語など）を除外し、重複も排除
    final distractors = pool
        .where((w) => w.id != word.id && optionOf(w) != optionOf(word))
        .map(optionOf)
        .toSet()
        .toList()
      ..shuffle(rng);

    final options = [
      optionOf(word),
      ...distractors.take(kanjiQuizOptionCount - 1),
    ]..shuffle(rng);

    return KanjiQuizQuestion(
      word: word,
      mode: questionMode,
      options: options,
      correctIndex: options.indexOf(optionOf(word)),
    );
  }).toList();
}
