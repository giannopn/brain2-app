import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/bill_status.dart';

/// Bills page card based on Figma node 875:5487.
/// Variants:
/// - General: left icon + title, right large status chip
/// - Detailed: left icon + title + subtitle, right amount + small status
/// - DetailedShared: same as Detailed with group-users icon
class BillsCard extends StatelessWidget {
  const BillsCard({
    super.key,
    this.type = BillsCardType.general,
    this.title = 'Bill',
    this.subtitle,
    this.amount,
    this.status = BillStatusType.paid,
    this.isShared = false,
    this.iconPath,
    this.iconColor,
    this.iconBackgroundColor,
    this.width = 356,
  });

  final BillsCardType type;
  final String title;
  final String? subtitle; // e.g., "in 2 days"
  final String? amount; // e.g., "-46.28€"
  final BillStatusType status;
  final bool isShared; // only relevant for DetailedShared
  final String? iconPath; // defaults to AppIcons.home
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final double width;

  // Typography (aligned with existing widgets)
  static const double _fontSizeTitle = 20;
  static const double _fontSizeSubtitle = 14;
  static const double _fontSizeAmount = 18;

  // Colors
  static const Color _textColor = Color(0xFF000000);
  static const Color _subtitleColor = Color(0xFF4B4B4B);
  static const Color _defaultIconBackground = Color(0xFFE8C4E8);
  static const Color _defaultIconColor = Color(0xFF000000);

  // Sizing
  static const double _iconSize = 56;
  static const double _padding = 10;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(_padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIcon(),
              const SizedBox(width: _gap),
              _buildTextSection(),
            ],
          ),
          _buildRightSection(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: _iconSize,
      height: _iconSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? _defaultIconBackground,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath ?? AppIcons.home,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            iconColor ?? _defaultIconColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    final hasSubtitle = type != BillsCardType.general && subtitle != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: _fontSizeTitle,
                fontWeight: FontWeight.w600,
                color: _textColor,
                height: 1,
              ),
            ),
            if (type == BillsCardType.detailedShared || isShared) ...[
              const SizedBox(width: 10),
              SvgPicture.asset(
                AppIcons.groupUsers,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  _textColor,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: _fontSizeSubtitle,
              fontWeight: FontWeight.w300,
              color: _subtitleColor,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightSection() {
    switch (type) {
      case BillsCardType.general:
        return BillStatus(status: status, size: BillStatusSize.large);
      case BillsCardType.detailed:
      case BillsCardType.detailedShared:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (amount != null) ...[
              Text(
                amount!,
                style: const TextStyle(
                  fontSize: _fontSizeAmount,
                  fontWeight: FontWeight.w400,
                  color: _textColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
            ],
            BillStatus(status: status, size: BillStatusSize.small),
          ],
        );
    }
  }
}

enum BillsCardType { general, detailed, detailedShared }
