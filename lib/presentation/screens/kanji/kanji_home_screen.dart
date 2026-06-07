import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kanji_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'kanji_card_screen.dart';
import 'kanji_quiz_screen.dart';

/// 現場の漢字 メニュー画面
class KanjiHomeScreen extends ConsumerWidget {
  const KanjiHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final allKanjiAsync = ref.watch(allKanjiWordsProvider);
    final favoritesAsync = ref.watch(favoriteKanjiWordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kanjiCardTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ヘッダー（説明と収録語数）
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('🏭', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.kanjiCardDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        allKanjiAsync.maybeWhen(
                          data: (words) => Text(
                            '${words.length}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
        ],
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
