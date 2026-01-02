import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';

enum NavigationIconVariant { inactive, active }

// Include 'library' to match the Figma bottom navigation presets
enum NavigationIconType { home, library, profile }

class NavigationIcon extends StatelessWidget {
  const NavigationIcon({
    super.key,
    this.type,
    required this.label,
    this.svgAssetPath,
    this.variant = NavigationIconVariant.inactive,
    this.onTap,
    this.width = 86,
    this.height = 72,
  });

  final NavigationIconType? type;
  final String label;
  final String? svgAssetPath;
  final NavigationIconVariant variant;
  final VoidCallback? onTap;
  final double width;
  final double height;

  // Figma bottom bar: white background, color changes on active item.
  // Use accent blue for active icons/text; black for inactive.
  static const Color _accentActive = Color(0xFF4E89DC);
  static const Color _textInactive = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final bool isActive = variant == NavigationIconVariant.active;
    final Color foregroundColor = isActive ? _accentActive : _textInactive;

    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _svgAssetForType() ?? AppIcons.circle,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _svgAssetForType() {
    if (svgAssetPath != null) return svgAssetPath;

    switch (type) {
      case NavigationIconType.home:
        return AppIcons.home;
      case NavigationIconType.library:
        return AppIcons.library;
      case NavigationIconType.profile:
        return AppIcons.userCircle;
      case null:
        return null;
    }
  }
}
