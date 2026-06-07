import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../../data/iap/product_catalog.dart';
import '../../../l10n/app_localizations.dart';

/// ストア画面（コンテンツパック一覧・購入・復元）
///
/// 価格・商品名はストア（ProductDetails）の値を表示する。
/// 「購入を復元」はApp Store審査の必須要件。
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(productsProvider);
    final entitlement = ref.watch(entitlementProvider);

    // 購入フローのエラー・承認待ちをSnackBarで通知
    ref.listen<EntitlementState>(entitlementProvider, (previous, next) {
      if (next.flowStatus == PurchaseFlowStatus.error &&
          previous?.flowStatus != PurchaseFlowStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage != null
                  ? '${l10n.storeError}: ${next.errorMessage}'
                  : l10n.storeError,
            ),
          ),
        );
        ref.read(entitlementProvider.notifier).clearError();
      }
      if (next.flowStatus == PurchaseFlowStatus.pending &&
          previous?.flowStatus != PurchaseFlowStatus.pending) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.storePending)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storeTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 説明（買い切りであることを明示）
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('🔓', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.storeDescription,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // パック一覧
          productsAsync.when(
            data: (products) =>
                _buildPackList(context, ref, products, entitlement),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text(l10n.storeUnavailable)),
            ),
          ),
          const SizedBox(height: 24),

          // 購入を復元（審査必須要件）
          OutlinedButton.icon(
            onPressed: entitlement.flowStatus == PurchaseFlowStatus.purchasing
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.storeRestoreStarted)),
                    );
                    ref.read(entitlementProvider.notifier).restore();
                  },
            icon: const Icon(Icons.restore),
            label: Text(l10n.storeRestore),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// パック一覧
  Widget _buildPackList(
    BuildContext context,
    WidgetRef ref,
    List<ProductDetails> products,
    EntitlementState entitlement,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (ProductCatalog.all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: Text(l10n.storeNoProducts)),
      );
    }

    return Column(
      children: ProductCatalog.all.map((pack) {
        ProductDetails? product;
        for (final p in products) {
          if (p.id == pack.productId) {
            product = p;
            break;
          }
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildPackCard(context, ref, pack, product, entitlement),
        );
      }).toList(),
    );
  }

  /// パックカード
  Widget _buildPackCard(
    BuildContext context,
    WidgetRef ref,
    ContentPack pack,
    ProductDetails? product,
    EntitlementState entitlement,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isJapanese = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );
    final isUnlocked = entitlement.isUnlocked(pack.packId);
    final isPurchasing =
        entitlement.flowStatus == PurchaseFlowStatus.purchasing;

    // 商品名はストア値を優先、未取得時はフォールバック
    final title = product?.title.isNotEmpty == true
        ? product!.title
        : (isJapanese ? pack.fallbackNameJa : pack.fallbackNameId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // パックアイコン
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.safetyYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(pack.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (product?.description.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                product!.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),

            // 購入ボタン / 購入済みバッジ
            if (isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.jisGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.jisGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.storePurchased,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.jisGreen,
                      ),
                    ),
                  ],
                ),
              )
            else if (product == null)
              // ストアから商品情報を取得できていない（オフライン等）
              SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.storeUnavailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPurchasing
                      ? null
                      : () {
                          ref
                              .read(entitlementProvider.notifier)
                              .buy(product);
                        },
                  child: isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('${l10n.storeBuy}  ${product.price}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
