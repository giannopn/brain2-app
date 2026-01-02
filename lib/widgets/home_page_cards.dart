import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/assets/subscription_default_icon.dart';

enum HomePageCardType { payment, subscription }

class HomePageCard extends StatelessWidget {
  const HomePageCard({
    super.key,
    this.cardType = HomePageCardType.payment,
    this.isShared = false,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.totalAmount,
    this.iconPath,
    this.iconColor,
    this.iconBackgroundColor,
    this.subtitleColor,
    this.width = 356,
  });

  final HomePageCardType cardType;
  final bool isShared;
  final String title;
  final String subtitle;
  final String amount;
  final String? totalAmount;
  final String? iconPath;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? subtitleColor;
  final double width;

  // Typography
  static const double _fontSizeTitle = 20;
  static const double _fontSizeSubtitle = 14;
  static const double _fontSizeAmount = 18;
  static const double _fontSizeTotal = 14;

  // Colors
  static const Color _textColor = Color(0xFF000000);
  static const Color _subtitleColor = Color(0xFF4B4B4B);
  static const Color _totalColor = Color(0xFFB3B3B3);
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
          // Left side: Icon + Title/Subtitle
          Row(
            children: [
              _buildIcon(),
              const SizedBox(width: _gap),
              _buildTitleSection(),
            ],
          ),
          // Right side: Amount
          _buildAmountSection(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (cardType == HomePageCardType.subscription) {
      return const SubscriptionDefaultIcon(
        variant: SubscriptionDefaultIconVariant.defaultVariant,
        size: _iconSize,
      );
    }

    // Payment icon
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

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
            if (isShared) ...[
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
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _fontSizeSubtitle,
            fontWeight: FontWeight.w300,
            color: subtitleColor ?? _subtitleColor,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amount,
          style: const TextStyle(
            fontSize: _fontSizeAmount,
            fontWeight: FontWeight.w400,
            color: _textColor,
            height: 1,
          ),
        ),
        if (totalAmount != null) ...[
          const SizedBox(height: 2),
          Text(
            totalAmount!,
            style: const TextStyle(
              fontSize: _fontSizeTotal,
              fontWeight: FontWeight.w300,
              color: _totalColor,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}
