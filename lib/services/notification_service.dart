import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      // Initialize time zones
      tz.initializeTimeZones();

      // Get the local timezone name from the platform
      String? timeZoneName;
      try {
        const platform = MethodChannel('flutter.io/timezone');
        timeZoneName = await platform.invokeMethod<String>('getLocalTimezone');
      } catch (e) {
        debugPrint(
          'NotificationService: Could not get timezone from platform: $e',
        );
      }

      // Set the location based on timezone name, or fallback to a reasonable default
      if (timeZoneName != null && timeZoneName.isNotEmpty) {
        try {
          tz.setLocalLocation(tz.getLocation(timeZoneName));
          debugPrint('NotificationService: Set timezone to $timeZoneName');
        } catch (e) {
          debugPrint(
            'NotificationService: Unknown timezone $timeZoneName, using UTC',
          );
          tz.setLocalLocation(tz.getLocation('UTC'));
        }
      } else {
        // Try to detect from DateTime offset as fallback
        final now = DateTime.now();
        final offset = now.timeZoneOffset;
        debugPrint(
          'NotificationService: Using offset-based timezone (offset: $offset)',
        );

        // Find a timezone that matches the current offset
        // Common timezones for testing
        final commonTimezones = [
          'America/New_York',
          'America/Chicago',
          'America/Denver',
          'America/Los_Angeles',
          'Europe/London',
          'Europe/Paris',
          'Asia/Tokyo',
          'Australia/Sydney',
        ];

        bool found = false;
        for (final tzName in commonTimezones) {
          try {
            final location = tz.getLocation(tzName);
            final tzTime = tz.TZDateTime.from(now, location);
            if (tzTime.timeZoneOffset == offset) {
              tz.setLocalLocation(location);
              debugPrint('NotificationService: Matched timezone to $tzName');
              found = true;
              break;
            }
          } catch (_) {}
        }

        if (!found) {
          tz.setLocalLocation(tz.getLocation('UTC'));
          debugPrint(
            'NotificationService: Could not match timezone, using UTC',
          );
        }
      }
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
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );
      // Request notification permission for Android 13+
      try {
        await androidImpl.requestNotificationsPermission();
        debugPrint('NotificationService: Android permission requested');

        // Request exact alarm permission for Android 13+
        await androidImpl.requestExactAlarmsPermission();
        debugPrint('NotificationService: Exact alarms permission requested');
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

          // Also request exact alarms permission
          try {
            await androidImpl.requestExactAlarmsPermission();
            debugPrint(
              'NotificationService: Exact alarms permission requested',
            );
          } catch (e) {
            debugPrint(
              'NotificationService: Exact alarms permission request: $e',
            );
          }
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

      // Check if exact alarms are permitted on Android
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        try {
          final canSchedule = await androidImpl.canScheduleExactNotifications();
          if (canSchedule == false) {
            debugPrint(
              'NotificationService: Exact alarms not permitted, requesting...',
            );
            await androidImpl.requestExactAlarmsPermission();
          }
        } catch (e) {
          debugPrint(
            'NotificationService: Could not check exact alarm permission: $e',
          );
        }
      }

      final int id = _stableIdFrom(transactionId);

      // Convert dueDate to local timezone first (it likely comes as UTC from Supabase)
      // Create a local DateTime with the same year/month/day as the dueDate
      final dueDateLocal = dueDate.toLocal();

      // 02:10 local time on due date
      final scheduledLocal = DateTime(
        dueDateLocal.year,
        dueDateLocal.month,
        dueDateLocal.day,
        10,
        00,
      );

      final nowTz = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTz = tz.TZDateTime.from(scheduledLocal, tz.local);

      // Only schedule in the future
      if (!scheduledTz.isAfter(nowTz)) {
        debugPrint(
          'NotificationService: skip schedule (past time) for $transactionId at $scheduledLocal',
        );
        return null;
      }

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      debugPrint('NotificationService: Attempting to schedule notification');
      debugPrint('NotificationService: ID=$id, Title=$title');
      debugPrint('NotificationService: Scheduled time: $scheduledTz');
      debugPrint('NotificationService: Now: $nowTz');
      debugPrint(
        'NotificationService: Time until: ${scheduledTz.difference(nowTz)}',
      );

      try {
        // Try to schedule with exact alarms first
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
        debugPrint(
          'NotificationService: Successfully scheduled with exactAllowWhileIdle',
        );
      } catch (exactError) {
        debugPrint('NotificationService: Exact schedule failed: $exactError');
        debugPrint(
          'NotificationService: Falling back to inexactAllowWhileIdle',
        );

        try {
          // Fallback to inexact alarms
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTz,
            details,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: transactionId,
          );
          debugPrint(
            'NotificationService: Successfully scheduled with inexactAllowWhileIdle',
          );
        } catch (inexactError) {
          debugPrint(
            'NotificationService: Inexact schedule also failed: $inexactError',
          );
          rethrow;
        }
      }

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

  /// Show an immediate test notification (useful for debugging)
  Future<void> showTestNotification() async {
    try {
      await requestPermissions();

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(
            'This is a test notification to verify that notifications are working correctly.',
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      await _plugin.show(
        999999, // Use a high ID unlikely to conflict
        'Test Notification',
        'This is a test notification',
        details,
      );

      debugPrint('NotificationService: Test notification shown');
    } catch (e, st) {
      debugPrint('NotificationService: showTestNotification error: $e');
      debugPrint('$st');
    }
  }

  /// Schedule a test notification 30 seconds in the future
  Future<void> scheduleTestNotification() async {
    try {
      await requestPermissions();

      // Check if exact alarms are permitted on Android
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        try {
          final canSchedule = await androidImpl.canScheduleExactNotifications();
          debugPrint(
            'NotificationService: Can schedule exact alarms: $canSchedule',
          );
          if (canSchedule == false) {
            debugPrint(
              'NotificationService: Requesting exact alarms permission...',
            );
            await androidImpl.requestExactAlarmsPermission();
          }
        } catch (e) {
          debugPrint(
            'NotificationService: Could not check exact alarm permission: $e',
          );
        }
      }

      final nowTz = tz.TZDateTime.now(tz.local);
      final scheduledTz = nowTz.add(const Duration(seconds: 30));

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(
            'This scheduled test notification was triggered 30 seconds after you tapped the button.',
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      );

      debugPrint('NotificationService: Scheduling test notification');
      debugPrint('NotificationService: Scheduled for: $scheduledTz');
      debugPrint('NotificationService: Now: $nowTz');

      try {
        // Try exact alarms first
        await _plugin.zonedSchedule(
          999998, // Use a high ID unlikely to conflict
          'Scheduled Test Notification',
          'This notification was scheduled for 30 seconds from now',
          scheduledTz,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint(
          'NotificationService: Test notification scheduled with exactAllowWhileIdle',
        );
      } catch (exactError) {
        debugPrint(
          'NotificationService: Exact test schedule failed: $exactError',
        );
        debugPrint(
          'NotificationService: Falling back to inexactAllowWhileIdle',
        );

        try {
          // Fallback to inexact alarms
          await _plugin.zonedSchedule(
            999998, // Use a high ID unlikely to conflict
            'Scheduled Test Notification',
            'This notification was scheduled for 30 seconds from now',
            scheduledTz,
            details,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
          debugPrint(
            'NotificationService: Test notification scheduled with inexactAllowWhileIdle',
          );
        } catch (inexactError) {
          debugPrint(
            'NotificationService: Inexact test schedule also failed: $inexactError',
          );
          rethrow;
        }
      }
    } catch (e, st) {
      debugPrint('NotificationService: scheduleTestNotification error: $e');
      debugPrint('$st');
    }
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
