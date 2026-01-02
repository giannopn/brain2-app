import 'package:flutter/widgets.dart';

enum ButtonLargeVariant { defaultVariant, primary }

class ButtonLarge extends StatelessWidget {
  const ButtonLarge({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonLargeVariant.defaultVariant,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonLargeVariant variant;
  final Widget? leading;

  static const double _height = 52;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  );

  static const Color _backgroundDefault = Color(0xFFF1F1F1);
  static const Color _foregroundDefault = Color(0xFF000000);
  static const Color _backgroundPrimary = Color(0xFF000000);
  static const Color _foregroundPrimary = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;

    switch (variant) {
      case ButtonLargeVariant.primary:
        backgroundColor = _backgroundPrimary;
        foregroundColor = _foregroundPrimary;
      case ButtonLargeVariant.defaultVariant:
        backgroundColor = _backgroundDefault;
        foregroundColor = _foregroundDefault;
    }

    final child = Container(
      height: _height,
      padding: _padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_height),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
