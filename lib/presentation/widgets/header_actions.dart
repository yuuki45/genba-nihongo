import 'package:flutter/material.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../../l10n/app_localizations.dart';

/// ヘッダー右上のアクションボタン（お気に入り・設定）
///
/// ボトムナビから外したお気に入り・設定への導線。
/// 各タブのAppBar actionsやホームのヒーローヘッダーで共通利用する。
List<Widget> buildHeaderActions(BuildContext context, {Color? color}) {
  final l10n = AppLocalizations.of(context)!;

  return [
    IconButton(
      icon: Icon(Icons.favorite_border, color: color),
      tooltip: l10n.navFavorites,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
      },
    ),
    IconButton(
      icon: Icon(Icons.settings_outlined, color: color),
      tooltip: l10n.navSettings,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
    ),
  ];
}
