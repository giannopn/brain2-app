import 'package:brain2/data/profile_repository.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/services/notification_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to sync all data from Supabase to local cache
class SyncService {
  SyncService._internal();

  static final SyncService instance = SyncService._internal();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  /// Whether a sync operation is currently in progress
  bool get isSyncing => _isSyncing;

  /// The last time a successful sync was completed
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Sync all data from Supabase to local cache
  ///
  /// This will fetch:
  /// - User profile
  /// - Bill categories
  /// - Bill transactions
  ///
  /// Returns true if sync was successful, false otherwise
  Future<bool> syncAll() async {
    if (_isSyncing) {
      debugPrint('SyncService: Sync already in progress, skipping...');
      return false;
    }

    _isSyncing = true;
    debugPrint('SyncService: Starting sync...');

    try {
      // Sync profile
      await ProfileRepository.instance.fetchProfile(forceRefresh: true);
      debugPrint('SyncService: Profile synced');

      // Sync bill categories
      await BillCategoriesRepository.instance.fetchBillCategories(
        forceRefresh: true,
      );
      debugPrint('SyncService: Bill categories synced');

      // Sync bill transactions
      await BillTransactionsRepository.instance.fetchBillTransactions(
        forceRefresh: true,
      );
      debugPrint('SyncService: Bill transactions synced');

      // Reschedule all notifications after sync (only if enabled)
      if (NotificationPreferences.instance.enableNotifications) {
        try {
          await BillTransactionsRepository.instance
              .syncNotificationsFromCached();
          debugPrint('SyncService: Notifications rescheduled');
        } catch (e, st) {
          debugPrint('SyncService: Notification reschedule failed: $e');
          debugPrint('$st');
        }
      } else {
        debugPrint('SyncService: Notifications disabled, skipping reschedule');
      }

      _lastSyncTime = DateTime.now();
      debugPrint('SyncService: Sync completed successfully at $_lastSyncTime');
      return true;
    } catch (e, stackTrace) {
      debugPrint('SyncService: Sync failed with error: $e');
      debugPrint('SyncService: Stack trace: $stackTrace');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Clear all cached data
  void clearAllCache() {
    ProfileRepository.instance.clearCache();
    BillCategoriesRepository.instance.clearCache();
    BillTransactionsRepository.instance.clearCache();
    _lastSyncTime = null;
    debugPrint('SyncService: All cache cleared');
  }
}
