import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/screens/home_page.dart';
import 'dart:async';

class PinVerificationPage extends StatefulWidget {
  final String email;

  const PinVerificationPage({super.key, required this.email});

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  final List<String> _digits = ['', '', '', '', '', ''];
  final FocusNode _textFieldFocusNode = FocusNode();
  final TextEditingController _hiddenController = TextEditingController();
  String _previousValue = '';
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes (for magic link)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.session != null && mounted) {
        // User signed in successfully via magic link - send to Home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    });

    // Listen to focus changes to update UI
    _textFieldFocusNode.addListener(() {
      setState(() {});
    });

    // Listen to text changes
    _hiddenController.addListener(_onTextChanged);
  }

  int get _filledCount => _digits.where((d) => d.isNotEmpty).length;

  void _onTextChanged() {
    final currentValue = _hiddenController.text;
    final diff = currentValue.length - _previousValue.length;

    if (diff < 0) {
      // Backspace(s) pressed
      int charsToDelete = -diff;
      int deletedCount = 0;
      for (int i = 5; i >= 0; i--) {
        if (_digits[i].isNotEmpty) {
          setState(() {
            _digits[i] = '';
          });
          deletedCount++;
          if (deletedCount >= charsToDelete) break;
        }
      }
    } else if (diff > 0) {
      // Character(s) added
      final newChars = currentValue.substring(_previousValue.length);
      for (int i = 0; i < newChars.length; i++) {
        final char = newChars[i];
        if (RegExp(r'[0-9]').hasMatch(char) && _filledCount < 6) {
          for (int j = 0; j < 6; j++) {
            if (_digits[j].isEmpty) {
              setState(() {
                _digits[j] = char;
              });
              break;
            }
          }
        }
      }

      // Auto-submit when all 6 digits are entered
      if (_filledCount == 6) {
        _verifyPin();
      }
    }

    _previousValue = currentValue;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _hiddenController.removeListener(_onTextChanged);
    _hiddenController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  String get _pin => _digits.join();

  Future<void> _verifyPin() async {
    final pin = _pin;

    if (pin.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: pin,
        type: OtpType.email,
      );

      // If successful, navigation will be handled by auth state listener
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid PIN. Please try again.';
      });
      // Clear the PIN
      setState(() {
        for (int i = 0; i < 6; i++) {
          _digits[i] = '';
        }
        _hiddenController.clear();
        _previousValue = '';
      });
      _textFieldFocusNode.requestFocus();
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = widget.email.split('@').first;

      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
        emailRedirectTo: 'brain2://login-callback',
        data: {'full_name': username},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent! Check your email.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to resend code. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Back button - fixed at top
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          'Verify your email',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Enter the 6-digit code sent to\n${widget.email}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // PIN input fields
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Hidden text field to capture keyboard input
                            // We use opacity 0 and position it behind the boxes but ensure it takes up space
                            // so the system acknowledges it as an interactive field.
                            Opacity(
                              opacity: 0,
                              child: SizedBox(
                                width: double.infinity,
                                height: 60, // Match roughly the height of boxes
                                child: TextField(
                                  controller: _hiddenController,
                                  focusNode: _textFieldFocusNode,
                                  keyboardType: TextInputType.number,
                                  autofocus: true,
                                  showCursor: false,
                                  enableInteractiveSelection: false,
                                  enabled: !_isLoading,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),
                            // Visual boxes
                            GestureDetector(
                              onTap: () {
                                _textFieldFocusNode.requestFocus();
                                SystemChannels.textInput.invokeMethod(
                                  'TextInput.show',
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  final isFocused =
                                      _textFieldFocusNode.hasFocus &&
                                      index == _filledCount;
                                  // When all 6 are filled, highlight the last one
                                  final isLastFilled =
                                      _textFieldFocusNode.hasFocus &&
                                      _filledCount == 6 &&
                                      index == 5;

                                  return Container(
                                    width: 45,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (isFocused || isLastFilled)
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFE0E0E0),
                                        width: (isFocused || isLastFilled)
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _digits[index],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 48),

                        // Divider with "OR"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Magic link info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 32,
                                color: Color(0xFF666666),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Check your email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Click the magic link in the email to sign in instantly',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend code button
                        TextButton(
                          onPressed: _isLoading ? null : _resendCode,
                          child: const Text(
                            'Didn\'t receive the code? Resend',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
