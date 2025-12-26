import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/theme/app_icons.dart';

/// A Settings-style row specifically for displaying bill status.
///
/// Left side: icon + label (eg. "Status").
/// Right side: a `BillStatus` chip that supports `paid`, `pending`, `overdue`.
///
/// Border radii follow the same grouping rules as `SettingsMenuPlace` to
/// match the Figma mixed-corners design when composing stacked rows.
class BillStatusMenu extends StatelessWidget {
  const BillStatusMenu({
    super.key,
    this.label = 'Status',
    required this.status,
    this.place = SettingsMenuPlace.defaultPlace,
    this.icon,
    this.onTap,
    this.width = double.infinity,
  });

  final String label;
  final BillStatusType status;
  final SettingsMenuPlace place;
  final Widget? icon;
  final VoidCallback? onTap;
  final double width;

  static const double _rowHeight = 52;
  // Figma: left/top/bottom = 15, right = 9. Trailing chip should be fully
  // visible regardless of the vertical padding applied to the label content.
  static const double _paddingL = 15;
  static const double _paddingR = 9;
  static const double _paddingTB = 15;
  static const Color _background = Color(0xFFF1F1F1);
  static const Color _textColor = Color(0xFF000000);

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
        // Default to the reload icon used in the Figma Status row
        SvgPicture.asset(AppIcons.mainComponent, width: 24, height: 24);

    final Widget trailing = BillStatus(
      status: status,
      size: BillStatusSize.large,
      cornerRadius: 9,
    );

    final content = Container(
      height: _rowHeight,
      decoration: BoxDecoration(color: _background, borderRadius: radius),
      child: Stack(
        children: [
          // Base content obeys the Figma paddings: left/top/bottom 15, right 9
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _paddingL,
              _paddingTB,
              _paddingR,
              _paddingTB,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                // Spacer space reserved; trailing is positioned independently
              ],
            ),
          ),
          // Trailing status chip is centered vertically and respects right=9
          Positioned(
            right: _paddingR,
            top: 0,
            bottom: 0,
            child: Center(child: trailing),
          ),
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
