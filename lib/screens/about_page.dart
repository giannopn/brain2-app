import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Typography
  static const double _fontSizeTitle = 24;
  static const double _fontSizeVersionLabel = 16;
  static const double _fontSizeVersionValue = 15;
  static const double _fontSizeAcknowledgmentTitle = 16;
  static const double _fontSizeAcknowledgmentText = 12;

  // Colors
  static const Color _textColor = Color(0xFF000000);

  // Sizing
  static const double _logoSize = 96;
  static const double _contentHorizontalPadding = 15;
  static const double _contentVerticalPadding = 10;
  static const double _contentGap = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar with back button and centered title
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: 'About',
            hideAddButton: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: _contentHorizontalPadding,
                vertical: _contentVerticalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/icon/brain2_logo_small_centered.png',
                    width: _logoSize,
                    height: _logoSize,
                  ),
                  const SizedBox(height: _contentGap),
                  // App Name
                  const Text(
                    'Brain 2',
                    style: TextStyle(
                      fontSize: _fontSizeTitle,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                      fontFamily: 'Inter',
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: _contentGap),
                  // Version Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Version',
                        style: TextStyle(
                          fontSize: _fontSizeVersionLabel,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: _fontSizeVersionValue,
                          fontWeight: FontWeight.w400,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _contentGap),
                  // Build Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Build',
                        style: TextStyle(
                          fontSize: _fontSizeVersionLabel,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '100',
                        style: TextStyle(
                          fontSize: _fontSizeVersionValue,
                          fontWeight: FontWeight.w400,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _contentGap),
                  // Acknowledgment Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Acknowledgment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fontSizeAcknowledgmentTitle,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This is a demo prototype for educational purposes.\nData shown are examples only.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _fontSizeAcknowledgmentText,
                          fontWeight: FontWeight.w400,
                          color: _textColor,
                          fontFamily: 'Inter',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
