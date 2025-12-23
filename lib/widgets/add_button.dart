import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    this.rotation = false,
    this.onPressed,
    this.icon,
  });

  final bool rotation;
  final VoidCallback? onPressed;
  final Widget? icon;

  static const double _size = 52;
  static const double _innerSize = 44;
  static const Color _background = Color(0xFFF1F1F1);

  @override
  Widget build(BuildContext context) {
    final Widget defaultIcon = SvgPicture.asset(
      AppIcons.plusBig,
      width: _innerSize,
      height: _innerSize,
      fit: BoxFit.contain,
    );

    final child = Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: _background,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.rotate(
          angle: rotation ? (225 * 3.14159265359 / 180) : 0,
          child: SizedBox(
            width: _innerSize,
            height: _innerSize,
            child: icon ?? defaultIcon,
          ),
        ),
      ),
    );

    if (onPressed == null) {
      return Semantics(button: true, enabled: false, child: child);
    }

    return Semantics(
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
