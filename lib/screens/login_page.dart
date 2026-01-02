import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/widgets/type_field.dart';
import 'package:brain2/widgets/button_large.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _signInWithMagicLink() async {
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
        _emailSent = true;
      });
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
      body: SafeArea(
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

              if (_emailSent) ...[
                // Success message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 48,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Check your email!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a magic link to\n${_emailController.text}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Click the link in the email to sign in. You can close this page.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ButtonLarge(
                  label: 'Send another link',
                  variant: ButtonLargeVariant.defaultVariant,
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                      _errorMessage = null;
                    });
                  },
                ),
              ] else ...[
                // Email input
                TypeField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _errorMessage,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _signInWithMagicLink(),
                ),
                const SizedBox(height: 24),

                // Sign in button
                ButtonLarge(
                  label: _isLoading ? 'Sending...' : 'Send Magic Link',
                  variant: ButtonLargeVariant.primary,
                  onPressed: _isLoading ? null : _signInWithMagicLink,
                ),
              ],

              const SizedBox(height: 24),

              // Info text
              const Text(
                'We\'ll send you a one-time link to sign in. No password needed!',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
