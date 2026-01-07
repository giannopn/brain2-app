import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/toggle_switch.dart';
import 'package:brain2/services/notification_service.dart';

// Settings manager to persist toggle states
class _NotificationSettings {
  static bool enableNotifications = true;
  static bool notifyOnDeadlines = true;
  static bool earlyReminders = true;
  static bool overdueNotifications = true;
}

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  late bool _enableNotifications;
  late bool _notifyOnDeadlines;
  late bool _earlyReminders;
  late bool _overdueNotifications;
  List<ScheduledNotificationOverview> _scheduled = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Load saved settings
    _enableNotifications = _NotificationSettings.enableNotifications;
    _notifyOnDeadlines = _NotificationSettings.notifyOnDeadlines;
    _earlyReminders = _NotificationSettings.earlyReminders;
    _overdueNotifications = _NotificationSettings.overdueNotifications;
    _refreshScheduled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: 'Notifications',
            hideAddButton: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  // Enable Notifications Section
                  _buildSettingItem(
                    label: 'Enable Notifications',
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                        _NotificationSettings.enableNotifications = value;
                      });
                    },
                    place: _SettingsPlace.single,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Text(
                      'Enable push notifications',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                        fontFamily: 'Inter',
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                  // Bills Notifications Section - only show if notifications are enabled
                  if (_enableNotifications) ...[
                    const SizedBox(height: 24),
                    // Bills Notifications Section Title
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 0, 14, 4),
                      child: Text(
                        'Bills Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Notify on Deadlines
                    _buildSettingItem(
                      label: 'Notify on Deadlines',
                      value: _notifyOnDeadlines,
                      onChanged: (value) {
                        setState(() {
                          _notifyOnDeadlines = value;
                          _NotificationSettings.notifyOnDeadlines = value;
                        });
                      },
                      place: _SettingsPlace.upper,
                    ),
                    const SizedBox(height: 4),
                    // Early Reminders
                    _buildSettingItem(
                      label: 'Early Reminders',
                      value: _earlyReminders,
                      onChanged: (value) {
                        setState(() {
                          _earlyReminders = value;
                          _NotificationSettings.earlyReminders = value;
                        });
                      },
                      place: _SettingsPlace.middle,
                    ),
                    const SizedBox(height: 4),
                    // Overdue Notifications
                    _buildSettingItem(
                      label: 'Overdue Notifications',
                      value: _overdueNotifications,
                      onChanged: (value) {
                        setState(() {
                          _overdueNotifications = value;
                          _NotificationSettings.overdueNotifications = value;
                        });
                      },
                      place: _SettingsPlace.lower,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local time: ${_formatNow()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scheduled notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Loading…'),
                          )
                        else if (_scheduled.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('No scheduled notifications'),
                          )
                        else
                          Column(
                            children: _scheduled
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F7F7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'When: ${_formatDateTime(s.scheduledTime)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'In: ${_formatDuration(s.timeUntil)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required _SettingsPlace place,
  }) {
    BorderRadius borderRadius;
    switch (place) {
      case _SettingsPlace.upper:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        );
        break;
      case _SettingsPlace.middle:
        borderRadius = BorderRadius.circular(4);
        break;
      case _SettingsPlace.lower:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        );
        break;
      case _SettingsPlace.single:
        borderRadius = BorderRadius.circular(18);
        break;
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF000000),
              fontFamily: 'Inter',
            ),
          ),
          ToggleSwitch(initialValue: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Future<void> _refreshScheduled() async {
    setState(() {
      _loading = true;
    });
    final list = await NotificationService.instance.getScheduledNotifications();
    setState(() {
      _scheduled = list;
      _loading = false;
    });
  }

  String _formatNow() => _formatDateTime(DateTime.now());

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  static String _formatDuration(Duration d) {
    if (d.isNegative) return 'now';
    final totalMinutes = d.inMinutes;
    final days = totalMinutes ~/ (60 * 24);
    final hours = (totalMinutes % (60 * 24)) ~/ 60;
    final minutes = totalMinutes % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

enum _SettingsPlace { upper, middle, lower, single }
