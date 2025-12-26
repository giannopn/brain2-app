import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';

/// Bill status chip based on Figma node 849:4995.
/// Variants: Paid | Pending | Overdue, each with Large (icon) and Small (no icon).
class BillStatus extends StatelessWidget {
  const BillStatus({
    super.key,
    required this.status,
    this.size = BillStatusSize.large,
    this.cornerRadius,
  });

  final BillStatusType status;
  final BillStatusSize size;
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    // Colors per status (from Figma)
    final Color background;
    final Color foreground;
    final String iconAsset; // only for large size

    switch (status) {
      case BillStatusType.paid:
        background = const Color(0xFFD4E8D2);
        foreground = const Color(0xFF2E7D32);
        iconAsset = AppIcons.checkedBox;
      case BillStatusType.pending:
        background = const Color(0xFFF2E3B3);
        foreground = const Color(0xFF8C6D1F);
        iconAsset = AppIcons.clock;
      case BillStatusType.overdue:
        background = const Color(0xFFF2C2C2);
        foreground = const Color(0xFF8C2B2B);
        iconAsset = AppIcons.wavyWarning;
    }

    final bool isSmall = size == BillStatusSize.small;

    final EdgeInsets padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    final double defaultRadius = isSmall ? 12 : 34;
    final BorderRadius borderRadius = BorderRadius.circular(
      cornerRadius ?? defaultRadius,
    );
    final double fontSize = isSmall ? 12 : 20;

    final String label = switch (status) {
      BillStatusType.paid => 'Paid',
      BillStatusType.pending => 'Pending',
      BillStatusType.overdue => 'Overdue',
    };

    final text = Text(
      label,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    );

    Widget child;
    if (isSmall) {
      child = text;
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          text,
          const SizedBox(width: 5),
          SizedBox(
            width: 24,
            height: 24,
            child: SvgPicture.asset(
              iconAsset,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: label,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

enum BillStatusType { paid, pending, overdue }

enum BillStatusSize { large, small }
