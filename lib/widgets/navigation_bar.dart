import 'package:flutter/material.dart';

import 'package:brain2/widgets/navigation_icons.dart';

class NavigationBarItem {
  const NavigationBarItem({required this.label, this.type, this.svgAssetPath})
    : assert(
        type != null || svgAssetPath != null,
        'Provide either a preset type or a custom SVG asset path',
      );

  final String label;
  final NavigationIconType? type;
  final String? svgAssetPath;
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({
    super.key,
    required this.items,
    this.activeIndex = 0,
    this.onItemSelected,
    this.width = 430,
    this.height = 85,
  }) : assert(items.length >= 2, 'Provide at least two navigation items');

  final List<NavigationBarItem> items;
  final int activeIndex;
  final ValueChanged<int>? onItemSelected;
  final double width;
  final double height;

  static const double _paddingH = 15;
  static const double _paddingV = 18;
  static const double _gap = 8;
  static const Color _background = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color.fromARGB(255, 255, 255, 255),
      padding: const EdgeInsets.symmetric(
        horizontal: _paddingH,
        vertical: _paddingV,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: Center(child: _buildItem(items[i], i))),
            if (i != items.length - 1) const SizedBox(width: _gap),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(NavigationBarItem item, int index) {
    final NavigationIconVariant variant = index == activeIndex
        ? NavigationIconVariant.active
        : NavigationIconVariant.inactive;

    return NavigationIcon(
      type: item.type,
      svgAssetPath: item.svgAssetPath,
      label: item.label,
      variant: variant,
      onTap: onItemSelected == null ? null : () => onItemSelected!(index),
      width: 86,
      height: 72,
    );
  }
}
