import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';

class SwipeBar extends StatefulWidget {
  final ValueChanged<double>? onDragEnd;
  final double initialProgress;

  const SwipeBar({super.key, this.onDragEnd, this.initialProgress = 0.0});

  @override
  State<SwipeBar> createState() => _SwipeBarState();
}

class _SwipeBarState extends State<SwipeBar> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  // Design constants
  static const double _barWidth = 400;
  static const double _barHeight = 90;
  static const double _circleSize = 70;
  static const double _circleRadius = 52;
  static const double _circlePadding = 10;
  static const Color _barColor = Color(0xFFFF4141);
  static const Color _circleBgColor = Color(0xFFC9C9C9);
  static const Color _arrowColor = Color(0xFF000000);

  double _getCirclePosition(double progress) {
    // Progress ranges from 0 to 1
    // Circle position ranges from _circlePadding to (_barWidth - _circleSize - _circlePadding)
    return _circlePadding +
        (progress * (_barWidth - _circleSize - 2 * _circlePadding));
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // The circle can move from _circlePadding to (_barWidth - _circleSize - _circlePadding)
    final minDragPosition = _circlePadding;
    final maxDragPosition = _barWidth - _circleSize - _circlePadding;

    // Clamp the touch position to the valid dragging range
    final clampedDx = localPosition.dx.clamp(minDragPosition, maxDragPosition);

    // Calculate progress (0 to 1) based on the clamped position
    final movableRange = maxDragPosition - minDragPosition;
    double newProgress = (clampedDx - minDragPosition) / movableRange;

    setState(() {
      _progress = newProgress;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    // If swiped all the way to the end (95% or more), trigger confirmation
    if (_progress >= 0.95) {
      widget.onDragEnd?.call(_progress);
    } else {
      // Otherwise, snap back to the beginning
      setState(() {
        _progress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Red bar background
        Container(
          width: _barWidth,
          height: _barHeight,
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(_circleRadius),
          ),
        ),
        // Draggable circle
        Positioned(
          left: _getCirclePosition(_progress),
          top: (_barHeight - _circleSize) / 2,
          child: GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                color: _circleBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: 0,
                  child: SvgPicture.asset(
                    AppIcons.arrow,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(_arrowColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
