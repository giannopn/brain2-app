import 'package:flutter/material.dart';

enum SettingsMenuPlace { defaultPlace, upper, middle, lower }

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    super.key,
    required this.label,
    this.place = SettingsMenuPlace.defaultPlace,
    this.rightText = false,
    this.rightLabel,
    this.icon,
    this.rightIcon,
    this.onTap,
    this.width = double.infinity,
  });

  final String label;
  final SettingsMenuPlace place;
  final bool rightText;
  final String? rightLabel;
  final Widget? icon;
  final Widget? rightIcon;
  final VoidCallback? onTap;
  final double width;

  static const double _rowHeight = 52;
  static const double _padding = 15;
  static const Color _background = Color(0xFFF1F1F1);
  static const Color _textColor = Color(0xFF000000);
  static const Color _accentColor = Color(0xFF007AFF);

  BorderRadius _borderRadiusForPlace(SettingsMenuPlace place) {
    const r4 = Radius.circular(4);
    const r18 = Radius.circular(18);

    switch (place) {
      case SettingsMenuPlace.upper:
        return const BorderRadius.only(
          topLeft: r18,
          topRight: r18,
          bottomLeft: r4,
          bottomRight: r4,
        );
      case SettingsMenuPlace.middle:
        return const BorderRadius.all(r4);
      case SettingsMenuPlace.lower:
        return const BorderRadius.only(
          topLeft: r4,
          topRight: r4,
          bottomLeft: r18,
          bottomRight: r18,
        );
      case SettingsMenuPlace.defaultPlace:
        return const BorderRadius.all(r18);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = _borderRadiusForPlace(place);

    final Widget leading =
        icon ??
        const Icon(Icons.settings_outlined, size: 24, color: _textColor);

    final Widget trailing = rightText
        ? Text(
            rightLabel ?? label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _accentColor,
            ),
          )
        : (rightIcon ??
              const Icon(Icons.chevron_right, size: 24, color: _textColor));

    final content = Container(
      height: _rowHeight,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(color: _background, borderRadius: radius),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: _textColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(
        button: true,
        enabled: false,
        child: SizedBox(width: width, child: content),
      );
    }

    return Semantics(
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(width: width, child: content),
      ),
    );
  }
}
