import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/phrase.dart';
import '../../../data/models/kanji_word.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/kanji_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../phrase_detail/phrase_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// 検索画面
///
/// フレーズと漢字語（現場の漢字）を横断検索する。
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TtsService _ttsService = TtsService();
  bool _isSearching = false;

  @override
  void dispose() {
    _ttsService.stop();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    ref.read(searchQueryProvider.notifier).state = query;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final kanjiResultsAsync = ref.watch(kanjiSearchResultsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // 検索バー
          _buildSearchBar(context),

          // 検索結果または初期状態
          Expanded(
            child: _isSearching
                ? searchResultsAsync.when(
                    data: (phrases) => kanjiResultsAsync.when(
                      data: (kanjiWords) =>
                          _buildSearchResults(context, phrases, kanjiWords),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('${l10n.errorOccurred}: $error'),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('${l10n.errorOccurred}: $error'),
                    ),
                  )
                : _buildInitialState(context),
          ),
        ],
      ),
    );
  }

  /// 検索バー
  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  /// 初期状態（検索前）
  Widget _buildInitialState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.searchTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.searchHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 32),
              _buildSearchTips(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 検索のヒント
  Widget _buildSearchTips(BuildContext context) {
    final tips = [
      {'icon': Icons.language, 'text': '複数の言語で検索可能'},
      {'icon': Icons.star, 'text': '部分一致で検索'},
      {'icon': Icons.category, 'text': 'カテゴリ別にフィルタ'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  tip['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  tip['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 検索結果（フレーズ + 漢字語）
  Widget _buildSearchResults(
    BuildContext context,
    List<Phrase> phrases,
    List<KanjiWord> kanjiWords,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (phrases.isEmpty && kanjiWords.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noSearchResults,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // キャッシュサイズを増やしてスクロールパフォーマンスを向上
      cacheExtent: 500,
      children: [
        // 件数（フレーズ + 漢字語の合計）
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            l10n.searchResults(phrases.length + kanjiWords.length),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),

        // フレーズセクション
        if (phrases.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.navPhrases),
          ...phrases.map((phrase) => _buildResultItem(context, phrase)),
        ],

        // 漢字語セクション
        if (kanjiWords.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.kanjiCardTitle),
          ...kanjiWords.map((word) => _buildKanjiResultItem(context, word)),
        ],
      ],
    );
  }

  /// セクション見出し（黄色のタグ + 見出し）
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.safetyYellow,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 漢字語の検索結果アイテム
  Widget _buildKanjiResultItem(BuildContext context, KanjiWord word) {
    final signColor = AppColors.kanjiCategoryColor(word.category);

    return Card(
      key: ValueKey('kanji_${word.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        leading: Container(
          width: 10,
          height: 40,
          decoration: BoxDecoration(
            color: signColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          word.word,
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('${word.reading} / ${word.indonesian}'),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            await _ttsService.speak(word.word);
          },
        ),
        onTap: () => _showKanjiDetail(context, word),
      ),
    );
  }

  /// 漢字語の詳細（ボトムシート）
  void _showKanjiDetail(BuildContext context, KanjiWord word) {
    final signColor = AppColors.kanjiCategoryColor(word.category);
    final onSignColor = AppColors.onKanjiCategoryColor(word.category);
    final isJapanese = ref.read(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );
    final description = isJapanese ? word.descriptionJa : word.descriptionId;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標識スタイルの表示語
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: signColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: onSignColor.withValues(alpha: 0.85),
                    width: 2,
                  ),
                ),
                child: Text(
                  word.word,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: onSignColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                word.reading,
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                word.romaji,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.indonesian,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: 36,
                color: Theme.of(context).colorScheme.primary,
                onPressed: () async {
                  await _ttsService.speak(word.word);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 検索結果アイテム
  Widget _buildResultItem(BuildContext context, Phrase phrase) {
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
        trailing: const Icon(Icons.chevron_right),
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
