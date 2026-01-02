import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/add_button.dart';

enum TextTopBarVariant { defaultActive, doneInactive }

class TextTopBar extends StatelessWidget {
  const TextTopBar({
    super.key,
    this.variant = TextTopBarVariant.defaultActive,
    this.title = 'Add new subscription',
    this.onBack,
    this.onAddPressed,
    this.paddingHorizontal = _paddingH,
    this.paddingTop = _paddingTop,
    this.paddingBottom = _paddingBottom,
  });

  final TextTopBarVariant variant;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAddPressed;
  final double paddingHorizontal;
  final double paddingTop;
  final double paddingBottom;

  static const double _paddingH = 15;
  static const double _paddingTop = 68;
  static const double _paddingBottom = 10;
  static const double _frameHeight = 130;
  static const Color _frameBackground = Colors.white;
  static const Color _backButtonColor = Color(0xFFF1F1F1);
  static const Color _textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final isActive = variant == TextTopBarVariant.defaultActive;

    return SizedBox(
      height: _frameHeight,
      child: Stack(
        children: [
          // Top bar background
          Positioned(
            left: 0,
            right: 0,
            top: paddingTop,
            bottom: 0,
            child: Container(
              color: _frameBackground,
              padding: EdgeInsets.fromLTRB(
                paddingHorizontal,
                0,
                paddingHorizontal,
                paddingBottom,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Back button
                  _buildBackButton(),
                  // Add button
                  _buildAddButton(isActive),
                ],
              ),
            ),
          ),
          // Title centered horizontally and vertically within the 52px button row
          Positioned(
            left: paddingHorizontal,
            right: paddingHorizontal,
            bottom: paddingBottom,
            height: 52,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _backButtonColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            AppIcons.backArrowBig,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isActive) {
    if (onAddPressed == null) {
      return const SizedBox(width: 52, height: 52);
    }

    return AddButton(
      onPressed: onAddPressed,
      backgroundColor: isActive
          ? const Color(0xFF007AFF)
          : const Color(0xFFB0CFFF),
      icon: SvgPicture.asset(
        AppIcons.checkWhiteBig,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          Color.fromARGB(255, 255, 255, 255),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

// Helper function to easily create variants
TextTopBar createDefaultTextTopBar({
  VoidCallback? onBack,
  VoidCallback? onAddPressed,
  String title = 'Add new subscription',
}) {
  return TextTopBar(
    variant: TextTopBarVariant.defaultActive,
    title: title,
    onBack: onBack,
    onAddPressed: onAddPressed,
  );
}

TextTopBar createDoneTextTopBar({
  VoidCallback? onBack,
  String title = 'Add new subscription',
}) {
  return TextTopBar(
    variant: TextTopBarVariant.doneInactive,
    title: title,
    onBack: onBack,
    onAddPressed: null,
  );
}
