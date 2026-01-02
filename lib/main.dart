import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          // Rebuild when auth state changes
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // If user is signed in, show home page, otherwise show login page
    if (session != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
