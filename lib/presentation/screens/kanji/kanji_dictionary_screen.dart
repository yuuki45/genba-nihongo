import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kanji_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/locked_content_banner.dart';
import '../../../data/iap/product_catalog.dart';
import '../../../data/models/kanji_character.dart';
import '../../../data/models/kanji_word.dart';
import '../../../l10n/app_localizations.dart';

/// 並び順
enum _DictSort { reading, category }

/// 漢字辞書画面
///
/// 収録語のインデックス（検索・並び替え）は無料。
/// 語詳細の「構成漢字」から開く単漢字エントリ（音訓読み・意味・逆引き）は
/// 漢字辞書パック（kanji_dict）で解錠される。
class KanjiDictionaryScreen extends ConsumerStatefulWidget {
  const KanjiDictionaryScreen({super.key});

  @override
  ConsumerState<KanjiDictionaryScreen> createState() =>
      _KanjiDictionaryScreenState();
}

class _KanjiDictionaryScreenState extends ConsumerState<KanjiDictionaryScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _DictSort _sort = _DictSort.reading;

  @override
  void dispose() {
    _ttsService.stop();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isJapanese => ref.read(settingsProvider).maybeWhen(
        data: (settings) => settings.languageCode == 'ja',
        orElse: () => false,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wordsAsync = ref.watch(allKanjiWordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kanjiDictTitle),
      ),
      body: Column(
        children: [
          // 検索バー + 並び替え
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: l10n.kanjiDictSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildSortChip(l10n.kanjiDictSortReading, _DictSort.reading),
                const SizedBox(width: 8),
                _buildSortChip(l10n.kanjiDictSortCategory, _DictSort.category),
              ],
            ),
          ),

          // 語リスト
          Expanded(
            child: wordsAsync.when(
              data: (words) => _buildWordList(context, words),
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

  Widget _buildSortChip(String label, _DictSort sort) {
    return FilterChip(
      label: Text(label),
      selected: _sort == sort,
      onSelected: (selected) {
        if (selected) setState(() => _sort = sort);
      },
    );
  }

  /// 検索・並び替えを適用した語リスト
  Widget _buildWordList(BuildContext context, List<KanjiWord> words) {
    final l10n = AppLocalizations.of(context)!;

    var filtered = words;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = words
          .where((w) =>
              w.word.contains(_query) ||
              w.reading.contains(_query) ||
              w.romaji.toLowerCase().contains(q) ||
              w.indonesian.toLowerCase().contains(q))
          .toList();
    }

    final sorted = [...filtered];
    if (_sort == _DictSort.reading) {
      sorted.sort((a, b) => a.reading.compareTo(b.reading));
    } else {
      final order = {
        for (var i = 0; i < KanjiCategory.all.length; i++)
          KanjiCategory.all[i].key: i
      };
      sorted.sort((a, b) {
        final byCategory =
            (order[a.category] ?? 99).compareTo(order[b.category] ?? 99);
        if (byCategory != 0) return byCategory;
        return a.reading.compareTo(b.reading);
      });
    }

    if (sorted.isEmpty) {
      return Center(child: Text(l10n.noSearchResults));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      itemCount: sorted.length,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        final word = sorted[index];
        final signColor = AppColors.kanjiCategoryColor(word.category);

        return Card(
          key: ValueKey('dict_${word.id}'),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            dense: true,
            leading: Container(
              width: 8,
              height: 36,
              decoration: BoxDecoration(
                color: signColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            title: Text(
              word.word,
              style: const TextStyle(
                fontFamily: AppTheme.displayFont,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text('${word.reading}｜${word.indonesian}'),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showWordDetail(context, word),
          ),
        );
      },
    );
  }

  /// 語の詳細（構成漢字付きボトムシート）
  void _showWordDetail(BuildContext context, KanjiWord word) {
    final l10n = AppLocalizations.of(context)!;
    final signColor = AppColors.kanjiCategoryColor(word.category);
    final onSignColor = AppColors.onKanjiCategoryColor(word.category);
    final description = _isJapanese ? word.descriptionJa : word.descriptionId;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
          child: Consumer(
            builder: (context, ref, _) {
              final isDictUnlocked = ref.watch(
                entitlementProvider.select(
                  (s) => s.isUnlocked(ProductCatalog.kanjiDictPack.packId),
                ),
              );
              final characters = ref
                      .watch(allKanjiCharactersProvider)
                      .maybeWhen(data: (c) => c, orElse: () => <KanjiCharacter>[]);
              final charMap = {for (final c in characters) c.character: c};

              // 語に含まれる漢字（重複除去・登場順）
              final chars = <String>[];
              for (final ch in word.word.split('')) {
                if (charMap.containsKey(ch) && !chars.contains(ch)) {
                  chars.add(ch);
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 標識スタイルの表示語
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
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
                      style: TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: onSignColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    word.reading,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
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
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    iconSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      await _ttsService.speak(word.word);
                    },
                  ),

                  // 構成漢字（漢字辞書パック）
                  if (chars.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Text(
                          isDictUnlocked
                              ? l10n.kanjiDictChars
                              : '${l10n.kanjiDictChars} 🔒',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isDictUnlocked) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.kanjiDictTapHint,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isDictUnlocked)
                      // 解錠済み: 読み・意味付きの行ボタン（タップで単漢字詳細）
                      ...chars.map((ch) {
                        final character = charMap[ch]!;
                        final readings = [
                          character.onReadings,
                          character.kunReadings,
                        ].where((r) => r.isNotEmpty).join('｜');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 2.0),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  ch,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.displayFont,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.safetyYellow,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              readings,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              character.meaningId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                _showCharacterDetail(context, character),
                          ),
                        );
                      })
                    else ...[
                      // 未購入: チップ表示 + 解錠バナー
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chars.map((ch) {
                          return Chip(
                            label: Text(
                              ch,
                              style: const TextStyle(
                                fontFamily: AppTheme.displayFont,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const LockedContentBanner(),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// 単漢字の詳細（音訓読み・意味・逆引き）
  void _showCharacterDetail(BuildContext context, KanjiCharacter character) {
    final l10n = AppLocalizations.of(context)!;
    final relatedWords = ref
        .read(allKanjiWordsProvider)
        .maybeWhen(data: (words) => words, orElse: () => <KanjiWord>[])
        .where((w) => w.word.contains(character.character))
        .toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          character.character,
                          style: const TextStyle(
                            fontFamily: AppTheme.displayFont,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: AppColors.safetyYellow,
                          ),
                        ),
                      ),
                    ),
                    if (character.jlptLevel != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.safetyYellow.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          character.jlptLevel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildReadingRow(l10n.kanjiDictOnYomi, character.onReadings),
              const SizedBox(height: 8),
              _buildReadingRow(l10n.kanjiDictKunYomi, character.kunReadings),
              const SizedBox(height: 12),
              Text(
                character.meaningId,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              if (relatedWords.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  l10n.kanjiDictRelated,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: relatedWords.map((word) {
                    return Chip(
                      label: Text('${word.word}（${word.reading}）'),
                      labelStyle: const TextStyle(fontSize: 13),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 読みの行（音読み/訓読み）
  Widget _buildReadingRow(String label, String readings) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              readings.isEmpty ? '—' : readings,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
