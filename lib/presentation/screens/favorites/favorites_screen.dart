import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/phrase.dart';
import '../../providers/phrase_provider.dart';
import '../phrase_detail/phrase_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// お気に入り一覧画面
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritePhrasesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navFavorites),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: favoritesAsync.when(
        data: (phrases) => _buildContent(context, ref, phrases),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('${l10n.errorOccurred}: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Phrase> phrases) {
    if (phrases.isEmpty) {
      return _buildEmptyState(context);
    }

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.pink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.favoritesCount(phrases.length),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              final phrase = phrases[index];
              return _buildPhraseItem(context, ref, phrase);
            },
            // キャッシュサイズを増やしてスクロールパフォーマンスを向上
            cacheExtent: 500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noFavoritesYet,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFavoritesHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseItem(BuildContext context, WidgetRef ref, Phrase phrase) {
    return Card(
      key: ValueKey(phrase.id), // パフォーマンス向上のためキーを追加
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: const Icon(
          Icons.favorite,
          color: Colors.pink,
          size: 24,
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
          ).then((_) {
            // お気に入り画面に戻った時にリストを更新
            ref.invalidate(favoritePhrasesProvider);
          });
        },
      ),
    );
  }
}
