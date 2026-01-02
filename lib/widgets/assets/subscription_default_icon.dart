import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SubscriptionDefaultIconVariant { defaultVariant, inactive }

class SubscriptionDefaultIcon extends StatelessWidget {
  const SubscriptionDefaultIcon({
    super.key,
    this.variant = SubscriptionDefaultIconVariant.defaultVariant,
    this.size = 56,
  });

  final SubscriptionDefaultIconVariant variant;
  final double size;

  // Colors from Figma design
  static const Color _backgroundDefault = Color(0xFF3D9C94);
  static const Color _backgroundInactive = Color(0xFFA5CFCB);
  static const Color _iconColorDefault = Color(0xFF000000);
  static const Color _iconColorInactive = Color(0xFF6B6B6B);

  // Icon dimensions
  static const double _paddingRatio = 12 / 56; // 12px padding on 56px container
  static const double _iconRatio = 32 / 56; // 32px icon on 56px container

  @override
  Widget build(BuildContext context) {
    final bool isInactive = variant == SubscriptionDefaultIconVariant.inactive;
    final Color backgroundColor = isInactive
        ? _backgroundInactive
        : _backgroundDefault;
    final Color iconColor = isInactive ? _iconColorInactive : _iconColorDefault;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * _paddingRatio),
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: SvgPicture.asset(
        'assets/svg_icons/CreditCardBig.svg',
        width: size * _iconRatio,
        height: size * _iconRatio,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
