import 'package:flutter/material.dart';

class ConsistencyBar extends StatelessWidget {
  const ConsistencyBar({super.key, required this.consistencyScore})
    : assert(
        consistencyScore >= 0 && consistencyScore <= 100,
        'Consistency score must be between 0 and 100',
      );

  final double consistencyScore;

  // Typography
  static const double _fontSizeLabel = 18;
  static const double _fontSizeScore = 48;

  // Colors
  static const Color _labelColor = Color(0xFF000000);
  static const Color _scoreColor = Color(0xFF000000);
  static const Color _backgroundBarColor = Color(0xFFd9d9d9);
  static const Color _progressBarColor = Color(0xFF39a74f);

  // Sizing
  static const double _barHeight = 16;
  static const double _barWidth = 225;
  static const double _barBorderRadius = 16;
  static const double _gapBetweenBarAndScore = 25;
  static const double _gapBetweenLabelAndBar = 5;

  @override
  Widget build(BuildContext context) {
    // Calculate the width of the progress bar based on consistency score
    final progressWidth = (_barWidth / 100) * consistencyScore;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left section: Label and progress bar
        Column(
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
                  width: _barWidth,
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: _backgroundBarColor,
                    borderRadius: BorderRadius.circular(_barBorderRadius),
                  ),
                ),
                // Progress bar (overlaid on background)
                Container(
                  width: progressWidth,
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: _progressBarColor,
                    borderRadius: BorderRadius.circular(_barBorderRadius),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(width: _gapBetweenBarAndScore),
        // Right section: Score
        Text(
          consistencyScore.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: _fontSizeScore,
            fontWeight: FontWeight.w600,
            color: _scoreColor,
            fontFamily: 'Inter',
            height: 1,
          ),
        ),
      ],
    );
  }
}
