import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/login_page.dart';
import 'package:brain2/services/notification_service.dart';
import 'package:brain2/services/notification_preferences.dart';
import 'package:brain2/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification preferences (must be first for sync_service)
  await NotificationPreferences.instance.init();

  // Initialize and request notification permissions early
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  await Supabase.initialize(
    url: 'https://rowicwwvaxcohuuhubqu.supabase.co',
    anonKey: 'sb_publishable_eTWXDszTMpUvo0nintospQ_d1fOyDPh',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      theme: ThemeData(fontFamily: 'Inter'),
    );
  }
}

/// Widget that determines whether to show login or home page based on auth state
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSyncComplete = false;

  @override
  void initState() {
    super.initState();

    // Sync data if user is already logged in
    _syncDataIfAuthenticated();

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        // Sync data when user signs in
        if (data.event == AuthChangeEvent.signedIn) {
          _syncDataIfAuthenticated();
        }
        setState(() {
          // Rebuild when auth state changes
        });
      }
    });
  }

  Future<void> _syncDataIfAuthenticated() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() {
        _isSyncComplete = false;
      });
      await SyncService.instance.syncAll();
      if (mounted) {
        setState(() {
          _isSyncComplete = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // If user is signed in, show home page, otherwise show login page
    if (session != null) {
      // Show loading indicator while syncing
      if (!_isSyncComplete) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
