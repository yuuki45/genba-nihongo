import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../widgets/language_segmented_control.dart';
import '../../../l10n/app_localizations.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/contact_screen.dart';
import '../store/store_screen.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: settings.when(
        data: (settingsData) => _buildSettingsContent(context, ref, settingsData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('${l10n.errorOccurred}: $error'),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      children: [
        // 表示設定セクション
        _buildSectionHeader(context, l10n.settingsDisplay),
        _buildLanguageSetting(context, ref, settings),
        _buildDarkModeSetting(context, ref, settings),
        const Divider(),

        // アプリ情報セクション
        _buildSectionHeader(context, l10n.settingsAppInfo),
        _buildAppInfoTile(context, l10n.settingsVersion, '1.0.0'),
        _buildAppInfoTile(context, l10n.settingsPhraseCount, '329'),
        _buildAppInfoTile(context, l10n.settingsDeveloper, 'Yuuki Odan'),
        _buildOfflineInfoTile(context, settings.languageCode),
        const Divider(),

        // コンテンツパック（ストア導線 + 購入の復元）
        _buildSectionHeader(context, l10n.storeTitle),
        _buildStoreTile(context),
        _buildRestoreTile(context, ref),
        const Divider(),

        // その他
        _buildSectionHeader(context, l10n.settingsOther),
        _buildAboutTile(context),
        const Divider(),

        // 法的情報
        _buildSectionHeader(context, settings.languageCode == 'ja' ? '法的情報' : 'Informasi Hukum'),
        _buildTermsOfServiceTile(context),
        _buildPrivacyPolicyTile(context),
        _buildContactTile(context),
      ],
    );
  }

  /// セクションヘッダー
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// 言語設定
  ///
  /// ホーム画面と同じセグメントコントロールで統一。
  /// ダイアログを開かずその場で切り替えられる。
  Widget _buildLanguageSetting(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language),
              SizedBox(width: 16),
              Text('言語 / Bahasa', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          LanguageSegmentedControl(),
        ],
      ),
    );
  }

  /// ダークモード設定
  Widget _buildDarkModeSetting(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return SwitchListTile(
      secondary: Icon(
        settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      title: Text(l10n.settingsDarkMode),
      subtitle: Text(settings.isDarkMode ? l10n.settingsDarkModeOn : l10n.settingsDarkModeOff),
      value: settings.isDarkMode,
      onChanged: (value) {
        ref.read(settingsProvider.notifier).setDarkMode(value);
      },
    );
  }

  /// コンテンツパック（ストア画面への導線）
  Widget _buildStoreTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.storefront),
      title: Text(l10n.storeTitle),
      subtitle: Text(l10n.storeDescription),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StoreScreen()),
        );
      },
    );
  }

  /// 購入の復元（App Store審査の必須要件。ストア画面に加えて設定にも置く）
  Widget _buildRestoreTile(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.restore),
      title: Text(l10n.storeRestore),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.storeRestoreStarted)),
        );
        ref.read(entitlementProvider.notifier).restore();
      },
    );
  }

  /// アプリ情報タイル
  Widget _buildAppInfoTile(BuildContext context, String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  /// オフライン対応情報タイル
  Widget _buildOfflineInfoTile(BuildContext context, String languageCode) {
    return ListTile(
      leading: const Icon(
        Icons.cloud_off,
        color: Colors.green,
      ),
      title: Text(languageCode == 'ja' ? 'オフライン対応' : 'Mode Offline'),
      subtitle: Text(
        languageCode == 'ja'
          ? 'インターネット接続不要'
          : 'Tidak perlu koneksi internet',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
    );
  }

  /// アプリについて
  Widget _buildAboutTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.help_outline),
      title: Text(l10n.settingsAbout),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: l10n.appTitle,
          applicationVersion: '1.0.0',
          applicationIcon: const FlutterLogo(size: 48),
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.aboutDescription1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDescription2,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  /// 利用規約タイル
  Widget _buildTermsOfServiceTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(l10n.termsOfService),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TermsOfServiceScreen(),
          ),
        );
      },
    );
  }

  /// プライバシーポリシータイル
  Widget _buildPrivacyPolicyTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: Text(l10n.privacyPolicy),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrivacyPolicyScreen(),
          ),
        );
      },
    );
  }

  /// お問い合わせタイル
  Widget _buildContactTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.mail_outline),
      title: Text(l10n.contact),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContactScreen(),
          ),
        );
      },
    );
  }
}
