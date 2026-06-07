import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ設定データクラス
class AppSettings {
  final bool isDarkMode; // ダークモード
  final String languageCode; // 言語コード ('ja' or 'id')

  AppSettings({
    required this.isDarkMode,
    required this.languageCode,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// 設定Notifier
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguageCode = 'language_code';

  /// 設定を読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
      // 主対象がインドネシア人実習生のため、初回起動はインドネシア語
      final languageCode = prefs.getString(_keyLanguageCode) ?? 'id';

      state = AsyncValue.data(
        AppSettings(
          isDarkMode: isDarkMode,
          languageCode: languageCode,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// ダークモードを設定
  Future<void> setDarkMode(bool isDark) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, isDark);

      state = AsyncValue.data(currentSettings.copyWith(isDarkMode: isDark));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 言語を設定
  Future<void> setLanguage(String languageCode) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguageCode, languageCode);

      state = AsyncValue.data(currentSettings.copyWith(languageCode: languageCode));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 設定をリセット
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDarkMode);
      await prefs.remove(_keyLanguageCode);

      state = AsyncValue.data(
        AppSettings(
          isDarkMode: false,
          languageCode: 'id',
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// 設定Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier();
});
