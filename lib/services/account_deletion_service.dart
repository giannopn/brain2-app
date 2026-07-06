import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/services/notification_service.dart';
import 'package:brain2/services/sync_service.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AccountDeletionService {
  AccountDeletionService._internal();

  static final AccountDeletionService instance =
      AccountDeletionService._internal();

  Future<void> deleteCurrentAccount() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    if (session == null) {
      throw const AccountDeletionException(
        'You must be signed in to delete your account.',
      );
    }

    try {
      final response = await client.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
        body: const {'confirmed': true},
      );

      final data = response.data;
      if (data is Map && data['ok'] != true) {
        throw AccountDeletionException(
          _messageFromResponse(data) ?? 'Account deletion failed.',
        );
      }
    } on FunctionException catch (error) {
      throw AccountDeletionException(_messageFromFunctionError(error));
    } catch (error) {
      if (error is AccountDeletionException) rethrow;
      throw AccountDeletionException(error.toString());
    }

    await NotificationService.instance.cancelAll();
    SyncService.instance.clearAllCache();

    try {
      await client.auth.signOut();
    } catch (_) {
      // The backend has already deleted the auth user; local cleanup above is enough.
    }
  }

  String _messageFromFunctionError(FunctionException error) {
    final details = error.details;
    if (details is Map) {
      final message = _messageFromResponse(details);
      if (message != null) return message;
    }
    if (details is String && details.trim().isNotEmpty) {
      return details;
    }
    return 'Account deletion failed. Please try again.';
  }

  String? _messageFromResponse(Map<dynamic, dynamic> response) {
    final error = response['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    return null;
  }
}
