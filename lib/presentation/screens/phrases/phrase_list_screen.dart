import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/locked_content_banner.dart';
import '../../../data/models/phrase.dart';
import '../../../data/models/category.dart';
import '../phrase_detail/phrase_detail_screen.dart';
import '../search/search_screen.dart';
import '../../services/tts_service.dart';
import '../../../l10n/app_localizations.dart';

/// フレーズ一覧画面
class PhraseListScreen extends ConsumerStatefulWidget {
  const PhraseListScreen({super.key});

  @override
  ConsumerState<PhraseListScreen> createState() => _PhraseListScreenState();
}

class _PhraseListScreenState extends ConsumerState<PhraseListScreen> {
  final TtsService _ttsService = TtsService();

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final selectedJlptLevel = ref.watch(selectedJlptLevelProvider);
    final phrasesAsync = ref.watch(filteredPhrasesProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPhrases),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // JLPTレベルタブ
          _buildJlptLevelTabs(context, ref, selectedJlptLevel),

          // カテゴリタブ
          categoriesAsync.when(
            data: (categories) => _buildCategoryTabs(context, ref, categories, selectedCategoryId),
            loading: () => const SizedBox(height: 60),
            error: (error, stack) => const SizedBox(height: 60),
          ),

          // フレーズリスト
          Expanded(
            child: phrasesAsync.when(
              data: (view) => _buildPhraseList(context, ref, view),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('${l10n.errorOccurred}: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// JLPTレベルタブ
  Widget _buildJlptLevelTabs(
    BuildContext context,
    WidgetRef ref,
    String? selectedJlptLevel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    const jlptLevels = ['N5', 'N4', 'N3', 'N2'];

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        children: [
          // すべてのレベル
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(l10n.allLevels),
              selected: selectedJlptLevel == null,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedJlptLevelProvider.notifier).state = null;
                }
              },
            ),
          ),

          // 各JLPTレベル
          ...jlptLevels.map((level) {
            final isSelected = selectedJlptLevel == level;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedJlptLevelProvider.notifier).state = level;
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// カテゴリタブ
  Widget _buildCategoryTabs(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    int? selectedCategoryId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // カテゴリ名は表示言語に追従させる
    final isJapanese = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );
    // ロック中（未購入パック）のカテゴリ
    final lockedCategoryIds = ref.watch(lockedCategoryIdsProvider).maybeWhen(
          data: (ids) => ids,
          orElse: () => const <int>{},
        );

    return Container(
      height: 60,
      color: Colors.grey[100],
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        children: [
          // すべてカテゴリ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(l10n.allCategories),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                }
              },
            ),
          ),

          // 各カテゴリ
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            final isLocked = lockedCategoryIds.contains(category.id);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocked) ...[
                      const Icon(Icons.lock, size: 14),
                      const SizedBox(width: 2),
                    ],
                    if (category.icon != null) ...[
                      Text(category.icon!),
                      const SizedBox(width: 4),
                    ],
                    Text(isJapanese ? category.nameJa : category.nameId),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedCategoryProvider.notifier).state =
                        category.id;
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// フレーズリスト
  ///
  /// ロック中カテゴリの場合はプレビュー数件 + 解錠バナーを表示する。
  Widget _buildPhraseList(
      BuildContext context, WidgetRef ref, PhraseListView view) {
    final l10n = AppLocalizations.of(context)!;
    final phrases = view.phrases;

    if (phrases.isEmpty) {
      return Center(
        child: Text(l10n.noPhrases),
      );
    }

    // ロックバナーを先頭に置くため、リスト項目数を調整
    final extraItems = view.isLockedPreview ? 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: phrases.length + extraItems,
      itemBuilder: (context, index) {
        if (view.isLockedPreview && index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LockedContentBanner(
              message: l10n.lockedPreviewMore(view.hiddenCount),
            ),
          );
        }
        final phrase = phrases[index - extraItems];
        return _buildPhraseListItem(context, ref, phrase);
      },
      // キャッシュサイズを増やしてスクロールパフォーマンスを向上
      cacheExtent: 500,
    );
  }

  /// フレーズリストアイテム
  Widget _buildPhraseListItem(BuildContext context, WidgetRef ref, Phrase phrase) {
    return Card(
      key: ValueKey(phrase.id), // パフォーマンス向上のためキーを追加
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Text(
          phrase.japanese,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              phrase.romaji,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phrase.indonesian,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline),
          iconSize: 32,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            await _ttsService.speak(phrase.japanese);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhraseDetailScreen(phrase: phrase),
            ),
          );
        },
      ),
    );
  }
}
