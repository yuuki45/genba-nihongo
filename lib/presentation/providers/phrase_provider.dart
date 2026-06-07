import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/phrase.dart';
import '../../data/models/category.dart';
import '../../data/repositories/phrase_repository.dart';

/// PhraseRepositoryのProvider
final phraseRepositoryProvider = Provider<PhraseRepository>((ref) {
  return PhraseRepository();
});

/// すべてのフレーズを取得するProvider
/// キャッシュを保持してパフォーマンスを向上
final allPhrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  // データはめったに変更されないためキャッシュを保持
  ref.keepAlive();
  final repository = ref.watch(phraseRepositoryProvider);
  return await repository.getAllPhrases();
});

/// すべてのカテゴリを取得するProvider
/// キャッシュを保持してパフォーマンスを向上
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  // カテゴリは変更されないためキャッシュを保持
  ref.keepAlive();
  final repository = ref.watch(phraseRepositoryProvider);
  return await repository.getAllCategories();
});

/// 日付をシードに「今日のフレーズ」を決定的に選ぶ
///
/// 同じ日は何度開いても同じフレーズになり、日付が変わると入れ替わる。
/// テスト容易性のためProviderから分離した純粋関数。
List<Phrase> selectDailyPhrases(List<Phrase> phrases, DateTime date, int count) {
  if (phrases.isEmpty) return [];
  final seed = date.year * 10000 + date.month * 100 + date.day;
  final shuffled = [...phrases]..shuffle(Random(seed));
  return shuffled.take(count).toList();
}

/// 今日の3フレーズを取得するProvider（日替わり固定）
final dailyPhrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  final phrases = await repository.getAllPhrases();
  return selectDailyPhrases(phrases, DateTime.now(), 3);
});

/// カテゴリIDとJLPTレベルでフィルタリングされたフレーズを取得するProvider
final filteredPhrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  final jlptLevel = ref.watch(selectedJlptLevelProvider);

  // すべてのフレーズを取得
  List<Phrase> phrases;
  if (categoryId == null) {
    phrases = await repository.getAllPhrases();
  } else {
    phrases = await repository.getPhrasesByCategory(categoryId);
  }

  // JLPTレベルでフィルタリング
  if (jlptLevel != null) {
    phrases = phrases.where((phrase) => phrase.jlptLevel == jlptLevel).toList();
  }

  return phrases;
});

/// カテゴリIDでフィルタリングされたフレーズを取得するProvider（後方互換性のため保持）
final phrasesByCategoryProvider =
    FutureProvider.family<List<Phrase>, int?>((ref, categoryId) async {
  final repository = ref.watch(phraseRepositoryProvider);

  if (categoryId == null) {
    return await repository.getAllPhrases();
  }

  return await repository.getPhrasesByCategory(categoryId);
});

/// お気に入りフレーズを取得するProvider
final favoritePhrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  return await repository.getFavoritePhrases();
});

/// 選択中のカテゴリIDを管理するProvider
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

/// 選択中のJLPTレベルを管理するProvider
final selectedJlptLevelProvider = StateProvider<String?>((ref) => null);

/// 検索クエリを管理するProvider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 検索結果を取得するProvider
/// 検索は頻繁に変わるためautoDisposeを使用
final searchResultsProvider = FutureProvider.autoDispose<List<Phrase>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(phraseRepositoryProvider);

  if (query.isEmpty) {
    return [];
  }

  return await repository.searchPhrases(query);
});

/// お気に入り状態を管理するProvider
final favoriteStateProvider = StateNotifierProvider.family<FavoriteStateNotifier, bool, int>(
  (ref, phraseId) => FavoriteStateNotifier(ref, phraseId),
);

/// お気に入り状態管理クラス
class FavoriteStateNotifier extends StateNotifier<bool> {
  final Ref ref;
  final int phraseId;

  FavoriteStateNotifier(this.ref, this.phraseId) : super(false) {
    _initialize();
  }

  Future<void> _initialize() async {
    final repository = ref.read(phraseRepositoryProvider);
    state = await repository.isFavorite(phraseId);
  }

  Future<void> toggle() async {
    final repository = ref.read(phraseRepositoryProvider);

    if (state) {
      await repository.removeFavorite(phraseId);
      state = false;
    } else {
      await repository.addFavorite(phraseId);
      state = true;
    }

    // お気に入り一覧を更新
    ref.invalidate(favoritePhrasesProvider);
  }
}
