import 'package:flutter/material.dart';
import '../screens/store/store_screen.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// ロックされたコンテンツの案内バナー
///
/// 未購入パックのコンテンツ箇所に表示し、ストア画面へ誘導する。
/// フェーズ1以降、N3/N2クイズのロックゲートや職種パックのプレビューで使用する。
class LockedContentBanner extends StatelessWidget {
  /// バナーに表示する補足メッセージ（省略時は共通文言）
  final String? message;

  const LockedContentBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.safetyYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.safetyYellow.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.ink, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? l10n.lockedContentMessage,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoreScreen()),
              );
            },
            child: Text(l10n.lockedContentUnlock),
          ),
        ],
      ),
    );
  }
}
