// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service responsible for scheduling and managing local notifications
/// for the Workly attendance reminder feature.
///
/// This is a singleton – access via [NotificationService.instance].
class NotificationService {
  // ---------------------------------------------------------------------------
  // Singleton boilerplate
  // ---------------------------------------------------------------------------

  static NotificationService? _instance;

  /// The shared instance of [NotificationService].
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Android notification channel identifier.
  static const String _channelId = 'workly_attendance';

  /// Android notification channel human-readable name.
  static const String _channelName = 'Nhắc nhở điểm danh';

  /// Android notification channel description.
  static const String _channelDescription =
      'Nhắc nhở bạn điểm danh ca làm việc hàng ngày';

  /// IANA timezone name for Vietnam Standard Time.
  static const String _vietnamTimezone = 'Asia/Ho_Chi_Minh';

  /// Notification ID for the 9:00 AM morning reminder.
  static const int _morningNotificationId = 1;

  /// Notification ID for the 9:00 PM (21:00) evening reminder.
  static const int _eveningNotificationId = 2;

  // ---------------------------------------------------------------------------
  // Plugin instance
  // ---------------------------------------------------------------------------

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialises the [FlutterLocalNotificationsPlugin] and timezone data.
  ///
  /// Must be called once at app startup (e.g. in `main()`) before any other
  /// method on this service.
  Future<void> initialize() async {
    // Set up timezone data and fix local timezone to Vietnam.
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_vietnamTimezone));

    // Android initialisation settings – use the default app icon.
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Create the Android notification channel explicitly so importance and
    // other properties are applied even on Android 8+.
    await _createNotificationChannel();
  }

  /// Creates (or updates) the dedicated Android notification channel.
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  /// Requests the POST_NOTIFICATIONS permission required on Android 13+.
  ///
  /// Returns `true` if the permission is (or was already) granted.
  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    final bool? granted =
        await androidPlugin.requestNotificationsPermission();

    return granted ?? false;
  }

  /// Returns `true` if the user has not revoked notification permissions.
  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    final bool? enabled =
        await androidPlugin.areNotificationsEnabled();

    return enabled ?? false;
  }

  // ---------------------------------------------------------------------------
  // Scheduling helpers
  // ---------------------------------------------------------------------------

  /// Returns the next [tz.TZDateTime] occurrence of [hour]:[minute] in Vietnam
  /// time. If that time has already passed today, the returned value is
  /// tomorrow at the same time.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final tz.Location vietnam = tz.getLocation(_vietnamTimezone);
    final tz.TZDateTime now = tz.TZDateTime.now(vietnam);

    tz.TZDateTime scheduled = tz.TZDateTime(
      vietnam,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past (or exactly now), push to tomorrow.
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Builds the [AndroidNotificationDetails] used for all reminders.
  AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

  /// Schedules a single daily notification at [hour]:[minute] Vietnam time.
  Future<void> _scheduleDailyAtTime({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: _androidDetails),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ---------------------------------------------------------------------------
  // Public scheduling API
  // ---------------------------------------------------------------------------

  /// Schedules both the 9:00 AM morning and 9:00 PM evening daily reminders.
  ///
  /// Safe to call multiple times – existing notifications with the same IDs
  /// are automatically replaced.
  Future<void> scheduleDailyReminders() async {
    // Morning reminder – 09:00
    await _scheduleDailyAtTime(
      id: _morningNotificationId,
      title: 'Workly',
      body: 'Đừng quên điểm danh ca ngày hôm nay! 🌅',
      hour: 9,
      minute: 0,
    );

    // Evening reminder – 21:00
    await _scheduleDailyAtTime(
      id: _eveningNotificationId,
      title: 'Workly',
      body: 'Đừng quên điểm danh ca tối hôm nay! 🌙',
      hour: 21,
      minute: 0,
    );
  }

  /// Cancels all scheduled notifications managed by this service.
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  /// Cancels a single scheduled notification identified by [id].
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  // ---------------------------------------------------------------------------
  // Conditional scheduling
  // ---------------------------------------------------------------------------

  /// Updates the notification schedule based on whether the user has any
  /// active work shifts.
  ///
  /// - If [hasActiveWorks] is `true`, both daily reminders are scheduled.
  /// - If [hasActiveWorks] is `false`, all pending reminders are cancelled.
  Future<void> updateNotificationSchedule(bool hasActiveWorks) async {
    if (hasActiveWorks) {
      await scheduleDailyReminders();
    } else {
      await cancelAllReminders();
    }
  }

  // ---------------------------------------------------------------------------
  // Testing
  // ---------------------------------------------------------------------------

  /// Shows an immediate (non-scheduled) notification for testing purposes.
  Future<void> showTestNotification() async {
    await _plugin.show(
      0,
      'Workly – Test',
      'Thông báo thử nghiệm từ Workly 🔔',
      NotificationDetails(android: _androidDetails),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification response callbacks
  // ---------------------------------------------------------------------------

  /// Called when the user taps a notification while the app is in the
  /// foreground or background.
  static void _onNotificationResponse(NotificationResponse response) {
    // TODO: Navigate to the attendance screen when the app is resumed.
    // This will be wired up via a global navigator key in a future iteration.
  }

  /// Top-level callback invoked when the user taps a notification while the
  /// app is fully terminated (background isolate).
  ///
  /// Must be a top-level or static function – cannot be a closure.
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(
      NotificationResponse response) {
    // Handled by the OS; the app will launch normally via main().
  }
}
