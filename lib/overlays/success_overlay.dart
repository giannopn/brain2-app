import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';

/// Full-screen success overlay used when marking a bill as paid.
/// Light green background with a large centered check icon.
class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({super.key});

  static const Color _background = Color(0xFFD4E8D2); // light green
  static const Color _foreground = Color(0xFF2E7D32); // green

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          AppIcons.checkedBox,
          colorFilter: const ColorFilter.mode(_foreground, BlendMode.srcIn),
        ),
      ),
    );
  }
}
