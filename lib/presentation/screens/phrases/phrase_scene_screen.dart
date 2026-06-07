import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/phrase_scene.dart';
import '../search/search_screen.dart';
import 'phrase_list_screen.dart';
import '../../../l10n/app_localizations.dart';

/// フレーズのシーン選択画面（ハブ）
///
/// 工場・日常・介護などのシーン別リンクを表示し、
/// 選択したシーンのフレーズ一覧画面へ遷移する。
class PhraseSceneScreen extends ConsumerWidget {
  const PhraseSceneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isJapanese = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );
    final lockedSceneKeys = ref.watch(lockedSceneKeysProvider).maybeWhen(
          data: (keys) => keys,
          orElse: () => const <String>{},
        );
    final allPhrasesAsync = ref.watch(allPhrasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPhrases),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: PhraseScene.all.map((scene) {
          final isLocked = lockedSceneKeys.contains(scene.key);
          // シーン内のフレーズ数（ロック有無に関わらず収録数を表示）
          final count = allPhrasesAsync.maybeWhen(
            data: (phrases) => phrases
                .where((p) => scene.categoryIds.contains(p.categoryId))
                .length,
            orElse: () => null,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildSceneTile(
              context,
              ref,
              scene: scene,
              isJapanese: isJapanese,
              isLocked: isLocked,
              count: count,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// シーンのタイル
  Widget _buildSceneTile(
    BuildContext context,
    WidgetRef ref, {
    required PhraseScene scene,
    required bool isJapanese,
    required bool isLocked,
    required int? count,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.safetyYellow.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(scene.icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Row(
          children: [
            if (isLocked) ...[
              const Icon(Icons.lock, size: 16),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                isJapanese ? scene.nameJa : scene.nameId,
                style: const TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          isJapanese ? scene.descriptionJa : scene.descriptionId,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.safetyYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          // シーンをまたいでフィルタ状態を持ち越さない
          ref.read(selectedCategoryProvider.notifier).state = null;
          ref.read(selectedJlptLevelProvider.notifier).state = null;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhraseListScreen(scene: scene),
            ),
          );
        },
      ),
    );
  }
}
