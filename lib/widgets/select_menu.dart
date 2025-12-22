import 'package:flutter/material.dart';

/// Figma: "Select Menu" (node 1058:7274)
///
/// Visual specs (from Figma):
/// - Width: 400
/// - Row height: 52
/// - Row padding: 15
/// - Gap between rows: 4
/// - Background: #F1F1F1
/// - Text: 18px, regular, black
/// - Check icon: 24px (right side)
/// - Corner radii:
///   - First row: top 18, bottom 4
///   - Middle rows: 4
///   - Last row: bottom 18, top 4
class SelectMenu extends StatelessWidget {
  const SelectMenu({
    super.key,
    this.items = const ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'],
    this.selectedIndex = 0,
    this.onSelected,
    this.width = 400,
  }) : assert(selectedIndex >= 0);

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final double width;

  static const double _rowHeight = 52;
  static const double _gap = 4;
  static const double _padding = 15;
  static const Color _background = Color(0xFFF1F1F1);

  @override
  Widget build(BuildContext context) {
    final int clampedSelectedIndex = selectedIndex.clamp(0, items.length - 1);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SelectMenuRow(
              label: items[i],
              selected: i == clampedSelectedIndex,
              enabled: onSelected != null && i != clampedSelectedIndex,
              borderRadius: _borderRadiusForIndex(i, items.length),
              onTap: () => onSelected?.call(i),
            ),
            if (i != items.length - 1) const SizedBox(height: _gap),
          ],
        ],
      ),
    );
  }

  BorderRadius _borderRadiusForIndex(int index, int length) {
    const r4 = Radius.circular(4);
    const r18 = Radius.circular(18);

    if (length <= 1) {
      return const BorderRadius.all(r18);
    }

    if (index == 0) {
      return const BorderRadius.only(
        topLeft: r18,
        topRight: r18,
        bottomLeft: r4,
        bottomRight: r4,
      );
    }

    if (index == length - 1) {
      return const BorderRadius.only(
        topLeft: r4,
        topRight: r4,
        bottomLeft: r18,
        bottomRight: r18,
      );
    }

    return const BorderRadius.all(r4);
  }
}

class _SelectMenuRow extends StatelessWidget {
  const _SelectMenuRow({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.borderRadius,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: SelectMenu._rowHeight,
      padding: const EdgeInsets.all(SelectMenu._padding),
      decoration: BoxDecoration(
        color: SelectMenu._background,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 24,
            height: 24,
            child: selected
                ? const Icon(Icons.check, size: 24, color: Colors.black)
                : const SizedBox(width: 24, height: 24),
          ),
        ],
      ),
    );

    if (!enabled) {
      return Semantics(
        button: true,
        enabled: false,
        selected: selected,
        child: child,
      );
    }

    return Semantics(
      button: true,
      enabled: true,
      selected: false,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
