import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ設定データクラス
class AppSettings {
  final bool isDarkMode; // ダークモード
  final String languageCode; // 言語コード ('ja' or 'id')
  final bool reminderEnabled; // 学習リマインダーの有効/無効
  final int reminderHour; // リマインダー時刻（時）
  final int reminderMinute; // リマインダー時刻（分）

  AppSettings({
    required this.isDarkMode,
    required this.languageCode,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
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

  // 学習リマインダー設定のキー（main.dartの再スケジュールでも参照する）
  static const String keyReminderEnabled = 'reminder_enabled';
  static const String keyReminderHour = 'reminder_hour';
  static const String keyReminderMinute = 'reminder_minute';
  static const String keyLanguageCode = _keyLanguageCode;

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
          reminderEnabled: prefs.getBool(keyReminderEnabled) ?? false,
          reminderHour: prefs.getInt(keyReminderHour) ?? 20,
          reminderMinute: prefs.getInt(keyReminderMinute) ?? 0,
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

  /// 学習リマインダーの有効/無効を設定
  Future<void> setReminderEnabled(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyReminderEnabled, enabled);

      state =
          AsyncValue.data(currentSettings.copyWith(reminderEnabled: enabled));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 学習リマインダーの時刻を設定
  Future<void> setReminderTime(int hour, int minute) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyReminderHour, hour);
      await prefs.setInt(keyReminderMinute, minute);

      state = AsyncValue.data(currentSettings.copyWith(
        reminderHour: hour,
        reminderMinute: minute,
      ));
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
