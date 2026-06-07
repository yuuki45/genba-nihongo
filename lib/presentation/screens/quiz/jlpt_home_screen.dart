import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/purchase_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/header_actions.dart';
import '../../widgets/locked_content_banner.dart';
import '../../../data/iap/product_catalog.dart';
import '../../../l10n/app_localizations.dart';
import 'quiz_screen.dart';

/// JLPT演習問題のハブ画面
///
/// レベル（N3/N2）× 分野（すべて・文法・語彙・漢字読み）を選んで演習を開始する。
/// N2は対策パック購入で解錠される。
class JlptHomeScreen extends ConsumerWidget {
  const JlptHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isN2Unlocked = ref.watch(
      entitlementProvider.select(
        (state) => state.isUnlocked(ProductCatalog.jlptPack.packId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeJlptBlockTitle),
        actions: buildHeaderActions(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // N3（無料）
          _buildLevelCard(
            context,
            title: l10n.quizTitle,
            description: l10n.quizCardDescription,
            accentColor: AppColors.ink,
            level: 'N3',
            isUnlocked: true,
          ),
          const SizedBox(height: 16),

          // N2（対策パック）
          _buildLevelCard(
            context,
            title: l10n.quizTitleN2,
            description: l10n.quizCardDescriptionN2,
            accentColor: AppColors.jisBlue,
            level: 'N2',
            isUnlocked: isN2Unlocked,
          ),
        ],
      ),
    );
  }

  /// レベルごとのカード（分野選択ボタン付き）
  Widget _buildLevelCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color accentColor,
    required String level,
    required bool isUnlocked,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // 分野（表示名はローカライズ、出題フィルタはデータ上のカテゴリ値）
    final categories = <(String label, String? value)>[
      (l10n.allCategoriesKanji, null),
      (l10n.quizCategoryGrammar, '文法'),
      (l10n.quizCategoryVocab, '語彙'),
      (l10n.quizCategoryKanjiReading, '漢字読み'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // レベルバッジ
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: accentColor == AppColors.ink
                          ? AppColors.safetyYellow
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            if (isUnlocked)
              // 分野選択ボタン
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            jlptLevel: level,
                            category: category.$2,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: Text(category.$1,
                        style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
              )
            else
              // 未購入: 解錠バナー
              const LockedContentBanner(),
          ],
        ),
      ),
    );
  }
}
