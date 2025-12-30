import 'package:flutter/material.dart';

class ToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({super.key, this.initialValue = false, this.onChanged});

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with SingleTickerProviderStateMixin {
  late bool _isOn;
  late AnimationController _animationController;

  // Design constants
  static const double _width = 64;
  static const double _height = 28;
  static const double _knobWidth = 39;
  static const double _knobHeight = 24;
  static const double _padding = 2;
  static const Color _onColor = Color(0xFF34C759);
  static const Color _offColor = Color(0x4D3C3C43); // rgba(60,60,67,0.3)
  static const Color _knobColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (_isOn) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOn = !_isOn;
      if (_isOn) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onChanged?.call(_isOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: Color.lerp(
                _offColor,
                _onColor,
                _animationController.value,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              children: [
                // Knob
                Positioned(
                  left:
                      _padding +
                      (_width - _knobWidth - 2 * _padding) *
                          _animationController.value,
                  top: (_height - _knobHeight) / 2,
                  child: Container(
                    width: _knobWidth,
                    height: _knobHeight,
                    decoration: BoxDecoration(
                      color: _knobColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
