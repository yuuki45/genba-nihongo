import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// 言語切替セグメントコントロール
///
/// トグルではなく両言語を常に並べて表示する。
/// 各選択肢はそれぞれの言語+国旗で表記されるため、表示言語に関わらず
/// インドネシア人ユーザーが「Bahasa Indonesia」を読んで選べる。
/// 主対象（インドネシア人実習生）に合わせてインドネシア語を先頭に置く。
class LanguageSegmentedControl extends ConsumerWidget {
  /// 墨色などの暗い背景上に置く場合はtrue（ホームのヒーローヘッダー用）
  final bool onDarkBackground;

  const LanguageSegmentedControl({super.key, this.onDarkBackground = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final containerColor = onDarkBackground
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = onDarkBackground
        ? Colors.white.withValues(alpha: 0.15)
        : theme.colorScheme.outlineVariant;
    final unselectedTextColor = onDarkBackground
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;

    return settingsAsync.when(
      data: (settings) => Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _LanguageOption(
                flag: '🇮🇩',
                label: 'Bahasa Indonesia',
                selected: settings.languageCode == 'id',
                unselectedTextColor: unselectedTextColor,
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLanguage('id'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _LanguageOption(
                flag: '🇯🇵',
                label: '日本語',
                selected: settings.languageCode == 'ja',
                unselectedTextColor: unselectedTextColor,
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLanguage('ja'),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// 言語切替の選択肢ボタン
///
/// 選択中はセーフティイエロー地×墨文字（標識スタイル）。
class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.unselectedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: selected ? AppColors.safetyYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.ink : unselectedTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
