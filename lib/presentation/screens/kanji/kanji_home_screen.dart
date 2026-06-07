import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kanji_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/kanji_word.dart';
import '../../../l10n/app_localizations.dart';
import 'kanji_card_screen.dart';
import 'kanji_dictionary_screen.dart';
import 'kanji_quiz_screen.dart';
import '../../widgets/header_actions.dart';

/// 現場の漢字 メニュー画面
class KanjiHomeScreen extends ConsumerWidget {
  const KanjiHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesAsync = ref.watch(favoriteKanjiWordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kanjiCardTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: buildHeaderActions(context, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 漢字辞書（インデックスは無料・単漢字詳細は辞書パック）
          _buildMenuTile(
            context,
            icon: Icons.auto_stories,
            color: Colors.indigo,
            title: l10n.kanjiDictTitle,
            description: l10n.kanjiDictMenuDesc,
            onTap: () => _push(context, const KanjiDictionaryScreen()),
          ),

          // 漢字カード学習
          _buildMenuTile(
            context,
            icon: Icons.style,
            color: Colors.blue,
            title: l10n.kanjiMenuCards,
            description: l10n.kanjiMenuCardsDesc,
            onTap: () => _push(context, const KanjiCardScreen()),
          ),

          // 読みクイズ
          _buildMenuTile(
            context,
            icon: Icons.record_voice_over,
            color: Colors.green,
            title: l10n.kanjiMenuReadingQuiz,
            description: l10n.kanjiMenuReadingQuizDesc,
            onTap: () => _push(
              context,
              const KanjiQuizScreen(mode: KanjiQuizMode.reading),
            ),
          ),

          // 意味クイズ
          _buildMenuTile(
            context,
            icon: Icons.translate,
            color: Colors.orange,
            title: l10n.kanjiMenuMeaningQuiz,
            description: l10n.kanjiMenuMeaningQuizDesc,
            onTap: () => _push(
              context,
              const KanjiQuizScreen(mode: KanjiQuizMode.meaning),
            ),
          ),

          // 苦手な漢字
          _buildMenuTile(
            context,
            icon: Icons.star,
            color: Colors.amber,
            title: l10n.kanjiMenuFavorites,
            description: l10n.kanjiMenuFavoritesDesc,
            trailing: favoritesAsync.maybeWhen(
              data: (words) => words.isNotEmpty ? '${words.length}' : null,
              orElse: () => null,
            ),
            onTap: () => _push(context, const KanjiCardScreen(favoritesOnly: true)),
          ),

          // 苦手クイズ（読み/意味ミックスで出題）
          _buildMenuTile(
            context,
            icon: Icons.bolt,
            color: Colors.deepOrange,
            title: l10n.kanjiFavoritesQuiz,
            description: l10n.kanjiFavoritesQuizDesc,
            onTap: () => _push(
              context,
              const KanjiQuizScreen(favoritesOnly: true),
            ),
          ),

          // カテゴリー別クイズ
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 8.0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.safetyYellow,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.kanjiCategoryQuizSection,
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...KanjiCategory.all.map(
            (category) => _buildCategoryQuizTile(context, ref, category),
          ),
        ],
      ),
    );
  }

  /// カテゴリー別クイズのタイル（読み/意味ミックスで出題）
  Widget _buildCategoryQuizTile(
    BuildContext context,
    WidgetRef ref,
    KanjiCategory category,
  ) {
    final isJapanese = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );
    final signColor = AppColors.kanjiCategoryColor(category.key);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: signColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(category.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          isJapanese ? category.nameJa : category.nameId,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _push(
          context,
          KanjiQuizScreen(category: category.key),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// メニュータイル
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
