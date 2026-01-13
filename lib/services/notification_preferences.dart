import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent notification preferences
class NotificationPreferences {
  NotificationPreferences._internal();

  static final NotificationPreferences instance =
      NotificationPreferences._internal();

  static const String _enableNotificationsKey = 'enable_notifications';
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize preferences (call once on app startup)
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Get whether notifications are enabled
  bool get enableNotifications {
    _checkInitialized();
    return _prefs.getBool(_enableNotificationsKey) ?? true;
  }

  /// Set whether notifications are enabled
  Future<void> setEnableNotifications(bool value) async {
    _checkInitialized();
    await _prefs.setBool(_enableNotificationsKey, value);
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw StateError(
        'NotificationPreferences not initialized. Call init() first.',
      );
    }
  }
}
