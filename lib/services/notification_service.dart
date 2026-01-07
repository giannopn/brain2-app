import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Info about a scheduled notification
class NotificationScheduleInfo {
  final DateTime scheduledTime;
  final Duration timeUntilNotification;

  NotificationScheduleInfo({
    required this.scheduledTime,
    required this.timeUntilNotification,
  });

  String get formattedTime {
    final days = timeUntilNotification.inDays;
    final hours = timeUntilNotification.inHours % 24;
    final minutes = timeUntilNotification.inMinutes % 60;

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ${minutes}m';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return 'shortly';
    }
  }
}

class ScheduledNotificationOverview {
  final String transactionId;
  final String title;
  final DateTime scheduledTime;

  const ScheduledNotificationOverview({
    required this.transactionId,
    required this.title,
    required this.scheduledTime,
  });

  Duration get timeUntil => scheduledTime.difference(DateTime.now());
}

/// NotificationService
/// - Wraps flutter_local_notifications
/// - Schedules local notifications for bill transaction due dates
///
/// IMPORTANT: Call NotificationService.instance.init() once during app startup
/// (e.g., in main() before runApp). This will initialize the plugin,
/// request permissions, and configure time zones.
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, ScheduledNotificationOverview> _scheduled = {};

  // Android notification channel for due bill reminders
  static const String _channelId = 'bill_due_channel';
  static const String _channelName = 'Bill Due Reminders';
  static const String _channelDescription =
      'Reminders for upcoming bill transaction deadlines';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize time zones and set local location
      tz.initializeTimeZones();
      final String localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (e, st) {
      // If time zone detection fails, default to UTC but keep going
      debugPrint('NotificationService: timezone init failed: $e');
      debugPrint('$st');
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // Initialize plugin
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    final bool? initialized = await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            debugPrint(
              'NotificationService: user tapped notification with payload: ${notificationResponse.payload}',
            );
          },
    );
    debugPrint('NotificationService initialized: $initialized');

    // Create Android channel explicitly (best practice on Android 8+)
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
      // Request notification permission for Android 13+
      try {
        await androidImpl.requestNotificationsPermission();
        debugPrint('NotificationService: Android permission requested');
      } catch (e) {
        debugPrint(
          'NotificationService: Android permission request (may be older version): $e',
        );
      }
    }

    // Request permissions on iOS/macOS
    final darwinImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (darwinImpl != null) {
      try {
        final granted = await darwinImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: false,
        );
        debugPrint('NotificationService: iOS permissions granted: $granted');
      } catch (e, st) {
        debugPrint('NotificationService: iOS permission request failed: $e');
        debugPrint('$st');
      }
    }

    _initialized = true;
    debugPrint('NotificationService: fully initialized');
  }

  /// Explicitly request notification permissions.
  /// Call this if you want to request permissions at a specific time
  /// (e.g., when user taps "enable notifications" button).
  Future<bool> requestPermissions() async {
    debugPrint('NotificationService: requesting permissions...');

    try {
      bool grantedAndroid = true;
      bool grantedDarwin = true;

      // Request Android permissions
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        try {
          final granted = await androidImpl.requestNotificationsPermission();
          final enabled = await androidImpl.areNotificationsEnabled();
          grantedAndroid = (granted ?? enabled) ?? false;
          debugPrint(
            'NotificationService: Android permission result: granted=$granted enabled=$enabled',
          );
        } catch (e) {
          debugPrint(
            'NotificationService: Android permission request failed: $e',
          );
          grantedAndroid = false;
        }
      }

      // Request iOS permissions
      final darwinImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (darwinImpl != null) {
        try {
          final granted = await darwinImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
          debugPrint('NotificationService: iOS permissions granted: $granted');
          grantedDarwin = granted ?? false;
        } catch (e, st) {
          debugPrint('NotificationService: iOS permission request failed: $e');
          debugPrint('$st');
          grantedDarwin = false;
        }
      }

      // Web or other platforms: assume granted if no specific implementation
      if (androidImpl == null && darwinImpl == null) {
        return true;
      }

      return grantedAndroid && grantedDarwin;
    } catch (e, st) {
      debugPrint('NotificationService: requestPermissions error: $e');
      debugPrint('$st');
      return false;
    }
  }

  /// Schedule a due-date notification at 02:10 local time on [dueDate]
  /// Returns [NotificationScheduleInfo] if scheduled successfully, null otherwise.
  /// - [transactionId] is used to derive a stable notification id
  /// - [title] is the notification title
  /// - [body] is the notification body
  Future<NotificationScheduleInfo?> scheduleDueNotification({
    required String transactionId,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    try {
      // Ensure permissions are requested before scheduling
      await requestPermissions();

      final int id = _stableIdFrom(transactionId);

      // 02:10 local time on due date
      final scheduledLocal = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        2,
        10,
      );

      final nowTz = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTz = tz.TZDateTime.from(scheduledLocal, tz.local);

      // If the scheduled time is already past, fall back to 1 minute from now
      if (!scheduledTz.isAfter(nowTz)) {
        scheduledTz = nowTz.add(const Duration(minutes: 1));
        debugPrint(
          'NotificationService: scheduled time was past; rescheduling in 1 minute at $scheduledTz',
        );
      }

      // Only schedule in the future
      if (!scheduledTz.isAfter(nowTz)) {
        debugPrint(
          'NotificationService: skip schedule (past time) for $transactionId at $scheduledLocal',
        );
        return null;
      }

      final details = NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: transactionId,
      );

      final timeUntil = scheduledTz.difference(tz.TZDateTime.now(tz.local));
      _scheduled[transactionId] = ScheduledNotificationOverview(
        transactionId: transactionId,
        title: title,
        scheduledTime: scheduledTz.toLocal(),
      );
      return NotificationScheduleInfo(
        scheduledTime: scheduledTz.toLocal(),
        timeUntilNotification: timeUntil,
      );
    } catch (e, st) {
      debugPrint('NotificationService: schedule error: $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<void> cancelForTransaction(String transactionId) async {
    try {
      final int id = _stableIdFrom(transactionId);
      await _plugin.cancel(id);
      _scheduled.remove(transactionId);
    } catch (e, st) {
      debugPrint('NotificationService: cancel error: $e');
      debugPrint('$st');
    }
  }

  Future<NotificationScheduleInfo?> rescheduleForTransaction({
    required String transactionId,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    try {
      await cancelForTransaction(transactionId);
      return await scheduleDueNotification(
        transactionId: transactionId,
        title: title,
        body: body,
        dueDate: dueDate,
      );
    } catch (e, st) {
      debugPrint('NotificationService: reschedule error: $e');
      debugPrint('$st');
      return null;
    }
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      _scheduled.clear();
    } catch (e, st) {
      debugPrint('NotificationService: cancelAll error: $e');
      debugPrint('$st');
    }
  }

  Future<List<ScheduledNotificationOverview>>
  getScheduledNotifications() async {
    return _scheduled.values.toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Stable, deterministic ID from a string (e.g., UUID)
  // Uses djb2 variant and clamps to positive 31-bit int
  int _stableIdFrom(String input) {
    int hash = 5381;
    for (final codeUnit in input.codeUnits) {
      hash = ((hash << 5) + hash) ^ codeUnit; // hash * 33 ^ c
    }
    return hash & 0x7fffffff; // ensure non-negative 31-bit
  }
}
