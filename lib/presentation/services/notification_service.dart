import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// ローカル通知サービス（学習リマインダー）
///
/// 完全にローカルで動作し、サーバーや外部サービスは使わない。
/// 通知許可は設定でリマインダーをONにしたときだけリクエストする
/// （起動直後の許可ダイアログは拒否率が高いため）。
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 学習リマインダーの通知ID（毎日同じIDで上書きスケジュール）
  static const int _dailyReminderId = 1;

  /// 通知文（表示言語に追従。ARBはBuildContextが必要なためここで持つ）
  static const Map<String, String> _titles = {
    'ja': '今日の日本語を学ぼう！',
    'id': 'Ayo belajar bahasa Jepang hari ini!',
  };
  static const Map<String, String> _bodies = {
    'ja': '今日の3フレーズが届いています',
    'id': '3 frasa hari ini sudah siap',
  };

  /// 初期化（多重呼び出しは無視される）
  Future<void> initialize() async {
    if (_initialized) return;

    // タイムゾーンの初期化（zonedScheduleに必要）
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // 取得に失敗してもデフォルト（UTC）で動作は継続する
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // 許可リクエストは初期化時には行わない（リマインダーON時のみ）
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// 通知許可をリクエストする
  ///
  /// 設定画面でリマインダーをONにしたときだけ呼ぶこと。
  Future<bool> requestPermission() async {
    await initialize();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  /// 毎日の学習リマインダーをスケジュールする
  ///
  /// 同じIDで上書きするため、再スケジュールしても重複しない。
  /// [languageCode] に応じた通知文になる（言語変更は次回スケジュール時に反映）。
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    await initialize();

    await _plugin.zonedSchedule(
      _dailyReminderId,
      _titles[languageCode] ?? _titles['id']!,
      _bodies[languageCode] ?? _bodies['id']!,
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '学習リマインダー / Pengingat Belajar',
          channelDescription: '毎日の学習リマインダー通知',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 正確なアラーム権限を不要にする（毎日のリマインダーに厳密さは不要）
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 毎日同時刻に繰り返し
    );
  }

  /// 学習リマインダーをキャンセルする
  Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(_dailyReminderId);
  }

  /// 指定時刻の直近の発火日時を返す（今日の時刻が過ぎていれば明日）
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
