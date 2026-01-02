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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.only(bottom: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F1F1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(child: Center(child: _buildItem(items[i], i))),
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
