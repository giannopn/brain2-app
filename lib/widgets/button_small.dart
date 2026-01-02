import 'package:flutter/widgets.dart';

enum ButtonSmallVariant { defaultVariant, active }

class ButtonSmall extends StatelessWidget {
  const ButtonSmall({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonSmallVariant.defaultVariant,
    this.minWidth,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonSmallVariant variant;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;

    switch (variant) {
      case ButtonSmallVariant.active:
        backgroundColor = const Color(0xFF000000);
        foregroundColor = const Color(0xFFF1F1F1);
      case ButtonSmallVariant.defaultVariant:
        backgroundColor = const Color(0xFFF1F1F1);
        foregroundColor = const Color(0xFF000000);
    }

    final child = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(37),
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      selected: variant == ButtonSmallVariant.active,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
