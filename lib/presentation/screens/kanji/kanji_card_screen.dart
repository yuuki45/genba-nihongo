import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kanji_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/kanji_word.dart';
import '../../../l10n/app_localizations.dart';

/// 漢字カード学習画面
///
/// カテゴリ選択チップ + スワイプで進むカード形式。
/// カードをタップすると表（漢字語）と裏（読み・意味・説明）が切り替わる。
/// [favoritesOnly]がtrueの場合は苦手漢字のみを表示する（復習モード）。
class KanjiCardScreen extends ConsumerStatefulWidget {
  final bool favoritesOnly;

  const KanjiCardScreen({super.key, this.favoritesOnly = false});

  @override
  ConsumerState<KanjiCardScreen> createState() => _KanjiCardScreenState();
}

class _KanjiCardScreenState extends ConsumerState<KanjiCardScreen> {
  final TtsService _ttsService = TtsService();

  /// 次のカードの端をチラ見せして「スワイプできる」ことを伝える
  final PageController _pageController = PageController(viewportFraction: 0.92);

  /// 現在のページ
  int _currentPage = 0;

  /// 裏面を表示中のカードのインデックス集合
  final Set<int> _flippedIndexes = {};

  @override
  void dispose() {
    _ttsService.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = widget.favoritesOnly
        ? ref.watch(favoriteKanjiWordsProvider)
        : ref.watch(filteredKanjiWordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.favoritesOnly ? l10n.kanjiMenuFavorites : l10n.kanjiMenuCards,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // カテゴリチップ（苦手モードでは非表示）
          if (!widget.favoritesOnly) _buildCategoryChips(context),

          // カード本体
          Expanded(
            child: wordsAsync.when(
              data: (words) => _buildCardPager(context, words),
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

  /// カテゴリ選択チップ
  Widget _buildCategoryChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedCategory = ref.watch(selectedKanjiCategoryProvider);
    final isJapanese = _isJapanese();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        children: [
          // すべて
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(l10n.allCategoriesKanji),
              selected: selectedCategory == null,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedKanjiCategoryProvider.notifier).state = null;
                  _resetPager();
                }
              },
            ),
          ),

          // 各カテゴリ
          ...KanjiCategory.all.map((category) {
            final isSelected = selectedCategory == category.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 4),
                    Text(isJapanese ? category.nameJa : category.nameId),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedKanjiCategoryProvider.notifier).state =
                        category.key;
                    _resetPager();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// カテゴリ切替時にページとめくり状態をリセット
  void _resetPager() {
    setState(() {
      _currentPage = 0;
      _flippedIndexes.clear();
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  /// カードページャー
  Widget _buildCardPager(BuildContext context, List<KanjiWord> words) {
    final l10n = AppLocalizations.of(context)!;

    if (words.isEmpty) {
      return Center(
        child: Text(
          widget.favoritesOnly ? l10n.kanjiNoFavorites : l10n.kanjiNoWords,
        ),
      );
    }

    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < words.length - 1;

    return Column(
      children: [
        // 進捗表示 + 前後ボタン（スワイプの代替手段にもなる）
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 32,
                onPressed: hasPrev ? () => _goToPage(_currentPage - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  '${_currentPage + 1} / ${words.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 32,
                onPressed: hasNext ? () => _goToPage(_currentPage + 1) : null,
              ),
            ],
          ),
        ),

        // カード（次のカードの端が見える）
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: words.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: _buildFlipCard(context, words[index], index),
              );
            },
          ),
        ),

        // スワイプ操作のヒント
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.kanjiSwipeHint,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 指定ページへアニメーション付きで移動
  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// タップで表裏が切り替わるカード
  Widget _buildFlipCard(BuildContext context, KanjiWord word, int index) {
    final isFlipped = _flippedIndexes.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isFlipped) {
            _flippedIndexes.remove(index);
          } else {
            _flippedIndexes.add(index);
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: isFlipped
            ? _buildCardBack(context, word, key: ValueKey('back_$index'))
            : _buildCardFront(context, word, key: ValueKey('front_$index')),
      ),
    );
  }

  /// カード表面（本物のJIS標識のように描画する）
  ///
  /// カテゴリごとに実際の標識の配色規則を適用する:
  /// 安全=黄/墨、設備=青/白、場所=緑/白、作業=墨/白、勤怠=赤/白
  Widget _buildCardFront(BuildContext context, KanjiWord word, {Key? key}) {
    final l10n = AppLocalizations.of(context)!;
    final signColor = AppColors.kanjiCategoryColor(word.category);
    final onSignColor = AppColors.onKanjiCategoryColor(word.category);
    final isJapanese = _isJapanese();
    final category = KanjiCategory.fromKey(word.category);

    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: signColor,
        borderRadius: BorderRadius.circular(18),
      ),
      // 標識の内枠線
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: onSignColor.withValues(alpha: 0.85),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // カテゴリラベル（標識の種別表示）
                    if (category != null)
                      Text(
                        isJapanese ? category.nameJa : category.nameId,
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: onSignColor.withValues(alpha: 0.75),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // 標識本文
                    Text(
                      word.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        color: onSignColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.kanjiTapToFlip,
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 13,
                        color: onSignColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFavoriteButton(word),
          ],
        ),
      ),
    );
  }

  /// カード裏面（読み・意味・説明）
  ///
  /// 表面の標識色をヘッダー帯として引き継ぎ、表裏のつながりを示す。
  Widget _buildCardBack(BuildContext context, KanjiWord word, {Key? key}) {
    final l10n = AppLocalizations.of(context)!;
    final isJapanese = _isJapanese();
    final description = isJapanese ? word.descriptionJa : word.descriptionId;
    final signColor = AppColors.kanjiCategoryColor(word.category);
    final onSignColor = AppColors.onKanjiCategoryColor(word.category);
    final theme = Theme.of(context);

    return Container(
      key: key,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // カテゴリ色のヘッダー帯（表面の標識とつながる）
              Container(
                width: double.infinity,
                color: signColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  word.word,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: onSignColor,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        word.reading,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.romaji,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        word.indonesian,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.kanjiWhereToSee,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // 音声再生ボタン
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        iconSize: 36,
                        color: theme.colorScheme.primary,
                        onPressed: () async {
                          await _ttsService.speak(word.word);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFavoriteButton(word),
        ],
      ),
    );
  }

  /// 苦手登録ボタン（カード右上）
  ///
  /// 標識色の上でも視認できるよう、白い円形チップに載せる。
  Widget _buildFavoriteButton(KanjiWord word) {
    if (word.id == null) return const SizedBox.shrink();
    final isFavorite = ref.watch(kanjiFavoriteStateProvider(word.id!));

    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? const Color(0xFFEEA000) : AppColors.ink,
            size: 26,
          ),
          onPressed: () {
            ref.read(kanjiFavoriteStateProvider(word.id!).notifier).toggle();
          },
        ),
      ),
    );
  }

  /// 表示言語が日本語かどうか
  bool _isJapanese() {
    final settingsAsync = ref.watch(settingsProvider);
    return settingsAsync.maybeWhen(
      data: (settings) => settings.languageCode == 'ja',
      orElse: () => true,
    );
  }
}
