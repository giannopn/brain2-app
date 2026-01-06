import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/widgets/type_field.dart';
import 'package:brain2/widgets/button_large.dart';
import 'package:brain2/screens/pin_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Extract username from email (part before @)
      final username = email.split('@').first;

      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'brain2://login-callback',
        data: {'full_name': username},
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Navigate to PIN verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinVerificationPage(email: email),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Title
                const Text(
                  'Brain2',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email input
                TypeField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _errorMessage,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _sendOTP(),
                ),
                const SizedBox(height: 24),

                // Sign in button
                ButtonLarge(
                  label: _isLoading ? 'Sending...' : 'Continue',
                  variant: ButtonLargeVariant.primary,
                  onPressed: _isLoading ? null : _sendOTP,
                ),

                const SizedBox(height: 24),

                // Info text
                const Text(
                  'We\'ll send you a 6-digit code and a magic link.\nUse either to sign in!',
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
