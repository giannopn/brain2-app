import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/toggle_switch.dart';
import 'package:brain2/services/notification_service.dart';
import 'package:brain2/services/notification_preferences.dart';
import 'package:brain2/data/bill_transactions_repository.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  late bool _enableNotifications;
  List<ScheduledNotificationOverview> _scheduled = const [];
  bool _loading = true;
  bool _showDebugControls = false;

  @override
  void initState() {
    super.initState();
    // Load saved settings from persistent storage
    _enableNotifications = NotificationPreferences.instance.enableNotifications;
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
                    onChanged: _onEnableNotificationsChanged,
                    place: _SettingsPlace.single,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
                    child: Text(
                      'Enable push notifications on deadlines',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF000000),
                        fontFamily: 'Inter',
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Show/Hide Debug Controls toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showDebugControls = !_showDebugControls;
                          });
                        },
                        icon: Icon(
                          _showDebugControls
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: const Color(0xFF6B7280),
                        ),
                        label: Text(
                          _showDebugControls
                              ? 'Hide Debug Controls'
                              : 'Show Debug Controls',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                  if (_showDebugControls)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Test notification button
                          ElevatedButton(
                            onPressed: () async {
                              await NotificationService.instance
                                  .showTestNotification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Test notification sent!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Send Test Notification'),
                          ),
                          const SizedBox(height: 8),
                          // Scheduled test notification button
                          ElevatedButton(
                            onPressed: () async {
                              await NotificationService.instance
                                  .scheduleTestNotification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Scheduled test notification for 30 seconds from now!',
                                    ),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34C759),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Schedule Test (30s)'),
                          ),
                          const SizedBox(height: 16),
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final filtered = list
        .where((s) => !s.scheduledTime.isBefore(startOfToday))
        .toList();
    setState(() {
      _scheduled = filtered;
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

  Future<void> _onEnableNotificationsChanged(bool value) async {
    if (!value) {
      setState(() {
        _enableNotifications = false;
      });
      await NotificationPreferences.instance.setEnableNotifications(false);
      try {
        await NotificationService.instance.cancelAll();
        await _refreshScheduled();
      } catch (e) {
        debugPrint('NotificationsSettings: cancelAll failed: $e');
      }
      return;
    }

    final granted = await NotificationService.instance.requestPermissions();
    if (!mounted) return;

    if (granted) {
      setState(() {
        _enableNotifications = true;
      });
      await NotificationPreferences.instance.setEnableNotifications(true);
      try {
        await BillTransactionsRepository.instance.syncNotificationsFromCached();
        await _refreshScheduled();
      } catch (e) {
        // Keep UI responsive even if reschedule fails
        debugPrint('NotificationsSettings: reschedule failed: $e');
      }
    } else {
      setState(() {
        _enableNotifications = false;
      });
      await NotificationPreferences.instance.setEnableNotifications(false);
      _showPermissionDeniedMessage();
    }
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Notifications are disabled. Please enable them in system settings.',
        ),
      ),
    );
  }
}

enum _SettingsPlace { upper, middle, lower, single }
