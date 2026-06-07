import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/phrase.dart';
import '../../data/models/category.dart';
import '../../data/repositories/phrase_repository.dart';
import 'purchase_provider.dart';

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

/// 今日の3フレーズを取得するProvider（日替わり固定・解錠済みのみ）
final dailyPhrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  final unlockedPackIds = ref.watch(
    entitlementProvider.select((state) => state.unlockedPackIds),
  );
  final phrases = await repository.getAllPhrases();
  final available =
      filterUnlockedContent(phrases, (phrase) => phrase.packId, unlockedPackIds);
  return selectDailyPhrases(available, DateTime.now(), 3);
});

/// ロック中カテゴリのプレビュー件数
const int phrasePreviewCount = 5;

/// フレーズ一覧の表示内容
///
/// ロック中カテゴリ（未購入パック）を選択した場合は、
/// 冒頭のプレビューのみ返し [isLockedPreview] をtrueにする。
typedef PhraseListView = ({
  List<Phrase> phrases,
  bool isLockedPreview,
  int hiddenCount,
});

/// カテゴリIDとJLPTレベルでフィルタリングされたフレーズを取得するProvider
///
/// 未購入パックのフレーズは除外する。ただし未購入カテゴリを
/// 直接選択した場合はプレビュー（冒頭5件）を返す。
final filteredPhrasesProvider = FutureProvider<PhraseListView>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  final jlptLevel = ref.watch(selectedJlptLevelProvider);
  final unlockedPackIds = ref.watch(
    entitlementProvider.select((state) => state.unlockedPackIds),
  );

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

  final available =
      filterUnlockedContent(phrases, (phrase) => phrase.packId, unlockedPackIds);

  // 未購入カテゴリを選択中（解錠分が0件で元データはある）→ プレビュー表示
  if (categoryId != null && available.isEmpty && phrases.isNotEmpty) {
    final preview = phrases.take(phrasePreviewCount).toList();
    return (
      phrases: preview,
      isLockedPreview: true,
      hiddenCount: phrases.length - preview.length,
    );
  }

  return (phrases: available, isLockedPreview: false, hiddenCount: 0);
});

/// ロック中（未購入パックのみで構成される）カテゴリIDを判定する純粋関数
///
/// テスト容易性のためProviderから分離。
Set<int> computeLockedCategoryIds(
  List<Phrase> phrases,
  Set<String> unlockedPackIds,
) {
  final byCategory = <int, List<Phrase>>{};
  for (final phrase in phrases) {
    byCategory.putIfAbsent(phrase.categoryId, () => []).add(phrase);
  }

  final locked = <int>{};
  byCategory.forEach((categoryId, categoryPhrases) {
    final hasUnlockedContent = categoryPhrases
        .any((phrase) => isContentUnlocked(phrase.packId, unlockedPackIds));
    if (!hasUnlockedContent) {
      locked.add(categoryId);
    }
  });
  return locked;
}

/// ロック中カテゴリIDの集合を取得するProvider（カテゴリタブのロック表示用）
final lockedCategoryIdsProvider = FutureProvider<Set<int>>((ref) async {
  final repository = ref.watch(phraseRepositoryProvider);
  final unlockedPackIds = ref.watch(
    entitlementProvider.select((state) => state.unlockedPackIds),
  );
  final phrases = await repository.getAllPhrases();
  return computeLockedCategoryIds(phrases, unlockedPackIds);
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

/// 検索結果を取得するProvider（解錠済みのみ）
/// 検索は頻繁に変わるためautoDisposeを使用
final searchResultsProvider = FutureProvider.autoDispose<List<Phrase>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(phraseRepositoryProvider);
  final unlockedPackIds = ref.watch(
    entitlementProvider.select((state) => state.unlockedPackIds),
  );

  if (query.isEmpty) {
    return [];
  }

  final results = await repository.searchPhrases(query);
  return filterUnlockedContent(results, (phrase) => phrase.packId, unlockedPackIds);
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
