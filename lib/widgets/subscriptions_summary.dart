import 'package:flutter/material.dart';

class SubscriptionsSummary extends StatelessWidget {
  const SubscriptionsSummary({
    super.key,
    this.width = 339,
    this.activeCount = 6,
    this.amount = '-27€',
    this.periodLabel = 'per month',
    this.indicatorCount = 6,
    this.indicatorColor = const Color(0xFF2EA39A),
  });

  final double width;
  final int activeCount;
  final String amount;
  final String periodLabel;
  final int indicatorCount;
  final Color indicatorColor;

  static const double _padding = 10;
  static const double _indicatorSize = 24;
  static const double _indicatorOverlap = 6;
  static const Color _textColor = Color(0xFF000000);
  static const Color _periodColor = Color(0xFF797979);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(_padding),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_buildLeftColumn(), _buildRightColumn()],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$activeCount Active',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textColor,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        _buildIndicators(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textColor,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          periodLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _periodColor,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    if (indicatorCount <= 0) return const SizedBox.shrink();

    final double step = _indicatorSize - _indicatorOverlap;
    final double totalWidth = indicatorCount * step + _indicatorOverlap;

    return SizedBox(
      height: _indicatorSize,
      width: totalWidth,
      child: Stack(
        children: List.generate(indicatorCount, (index) {
          return Positioned(
            left: index * step,
            child: Container(
              width: _indicatorSize,
              height: _indicatorSize,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                border: Border.all(color: _textColor, width: 1),
              ),
            ),
          );
        }),
      ),
    );
  }
}
