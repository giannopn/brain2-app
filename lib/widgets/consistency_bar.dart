import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ConsistencyBar extends StatefulWidget {
  const ConsistencyBar({super.key, required this.consistencyScore})
    : assert(
        consistencyScore >= 0 && consistencyScore <= 100,
        'Consistency score must be between 0 and 100',
      );

  final double consistencyScore;

  @override
  State<ConsistencyBar> createState() => _ConsistencyBarState();
}

class _ConsistencyBarState extends State<ConsistencyBar>
    with TickerProviderStateMixin {
  // Typography
  static const double _fontSizeLabel = 18;
  static const double _fontSizeScore = 48;

  // Colors
  static const Color _labelColor = Color(0xFFFFFFFF);
  static const Color _scoreColor = Color(0xFFFFFFFF);
  static const Color _backgroundBarColor = Color(0xFF333333);
  static const Color _progressBarColor = Color(0xFF39a74f);

  // Card styling
  static const double _cardBorderRadius = 18;
  static const double _cardPadding = 24;
  static const double _barHeight = 16;
  static const double _barBorderRadius = 16;
  static const double _gapBetweenBarAndScore = 25;
  static const double _gapBetweenLabelAndBar = 10;

  // Parallax Translation & Shine
  static const double _maxTranslationPixels = 4.0; // Subtle translation
  static const double _shineOpacity = 0.35; // Premium shine
  static const double _sensorSmoothingFactor = 0.08; // Smoother low-pass filter
  static const double _recenterDamping = 0.99; // Gentle recentering

  // Sensor subscriptions
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Translation and shine state
  double _translateX = 0.0; // Horizontal translation offset
  double _translateY = 0.0; // Vertical translation offset
  double _shineX = 0.5; // Shine position X (0.0 - 1.0)
  double _shineY = 0.5; // Shine position Y (0.0 - 1.0)
  late AnimationController _recenterController;

  @override
  void initState() {
    super.initState();
    _recenterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSensorListeners();
  }

  void _initSensorListeners() {
    try {
      _gyroscopeSubscription = gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          if (!mounted) return;

          setState(() {
            // Apply low-pass filter for smooth sensor values
            _translateX =
                _translateX * (1 - _sensorSmoothingFactor) +
                (event.y * _sensorSmoothingFactor * _maxTranslationPixels);
            _translateY =
                _translateY * (1 - _sensorSmoothingFactor) +
                (-event.x * _sensorSmoothingFactor * _maxTranslationPixels);

            // Clamp translation to max pixels
            _translateX = _translateX.clamp(
              -_maxTranslationPixels,
              _maxTranslationPixels,
            );
            _translateY = _translateY.clamp(
              -_maxTranslationPixels,
              _maxTranslationPixels,
            );

            // Update shine position based on translation
            final normalizedX = _translateX / _maxTranslationPixels;
            final normalizedY = _translateY / _maxTranslationPixels;
            _shineX = (0.5 + normalizedX * 0.25).clamp(0.2, 0.8);
            _shineY = (0.5 + normalizedY * 0.25).clamp(0.2, 0.8);
          });

          // Reset recentering animation when motion detected
          if (_recenterController.isCompleted) {
            _recenterController.forward(from: 0.0);
          }
        },
        onError: (e) {
          debugPrint('Gyroscope error: $e');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Gyroscope initialization error (non-critical): $e');
      // Effect will gracefully degrade - card will be static but still functional
    }
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _recenterController.dispose();
    super.dispose();
  }

  /// Smooth recentering: gradually return translation to neutral
  void _applyRecentering(double progress) {
    final dampingFactor = pow(_recenterDamping, progress * 2.0).toDouble();
    _translateX *= dampingFactor;
    _translateY *= dampingFactor;

    // Update shine position during recentering
    final normalizedX = _translateX / _maxTranslationPixels;
    final normalizedY = _translateY / _maxTranslationPixels;
    _shineX = (0.5 + normalizedX * 0.25).clamp(0.2, 0.8);
    _shineY = (0.5 + normalizedY * 0.25).clamp(0.2, 0.8);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to recentering animation
    _recenterController.addListener(() {
      if (!mounted) return;
      _applyRecentering(_recenterController.value);
      setState(() {});
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Apply 3D perspective transform
        final contentWidget = Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left section: Label and progress bar (expands to fill available space minus score)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    'Consistency Score',
                    style: const TextStyle(
                      fontSize: _fontSizeLabel,
                      fontWeight: FontWeight.w600,
                      color: _labelColor,
                      fontFamily: 'Inter',
                      height: 1,
                    ),
                  ),
                  SizedBox(height: _gapBetweenLabelAndBar),
                  // Progress bar container
                  Stack(
                    children: [
                      // Background bar
                      Container(
                        width: double.infinity,
                        height: _barHeight,
                        decoration: BoxDecoration(
                          color: _backgroundBarColor,
                          borderRadius: BorderRadius.circular(_barBorderRadius),
                        ),
                      ),
                      // Progress bar (overlaid on background)
                      FractionallySizedBox(
                        widthFactor: widget.consistencyScore / 100,
                        child: Container(
                          height: _barHeight,
                          decoration: BoxDecoration(
                            color: _progressBarColor,
                            borderRadius: BorderRadius.circular(
                              _barBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: _gapBetweenBarAndScore),
            // Right section: Score (fixed width)
            SizedBox(
              width: 90,
              child: Text(
                widget.consistencyScore.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: _fontSizeScore,
                  fontWeight: FontWeight.w600,
                  color: _scoreColor,
                  fontFamily: 'Inter',
                  height: 1,
                ),
                textAlign: TextAlign.right,
                softWrap: false,
              ),
            ),
          ],
        );

        // Premium card with parallax translation and shine overlay
        return Transform.translate(
          offset: Offset(_translateX, _translateY),
          child: Stack(
            children: [
              // Card background with gradient
              Container(
                padding: const EdgeInsets.all(_cardPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_cardBorderRadius),
                  // Premium dark gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1a1a1a), const Color(0xFF0f0f0f)],
                  ),
                  // Subtle shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: contentWidget,
              ),
              // Gloss/shine overlay
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return RadialGradient(
                      center: Alignment(_shineX * 2 - 1, _shineY * 2 - 1),
                      radius: 1.5,
                      colors: [
                        Colors.white.withOpacity(_shineOpacity),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.screen,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cardBorderRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
