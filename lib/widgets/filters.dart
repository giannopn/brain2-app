import 'package:flutter/widgets.dart';

import 'button_small.dart';

/// Filters widget based on Figma component (node 1058:7902).
///
/// Shows three small pill buttons with customizable labels.
/// The active button is rendered with a black background and light text,
/// matching the existing `ButtonSmall` styles.
class Filters extends StatelessWidget {
  const Filters({
    super.key,
    this.active = FilterActive.all,
    this.onChanged,
    this.labelAll = 'All',
    this.labelSecond = 'Pending',
    this.labelThird = 'Overdue',
  });

  /// Which filter is currently active.
  final FilterActive active;

  /// Called when a filter button is tapped.
  final ValueChanged<FilterActive>? onChanged;

  /// Label for the first filter button.
  final String labelAll;

  /// Label for the second filter button.
  final String labelSecond;

  /// Label for the third filter button.
  final String labelThird;

  @override
  Widget build(BuildContext context) {
    ButtonSmall buildButton(String label, FilterActive value) {
      final isActive = active == value;
      return ButtonSmall(
        label: label,
        variant: isActive
            ? ButtonSmallVariant.active
            : ButtonSmallVariant.defaultVariant,
        onPressed: onChanged == null ? null : () => onChanged!(value),
        minWidth: 50,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildButton(labelAll, FilterActive.all),
        const SizedBox(width: 10),
        buildButton(labelSecond, FilterActive.second),
        const SizedBox(width: 10),
        buildButton(labelThird, FilterActive.third),
      ],
    );
  }
}

/// Variants for the active button state.
enum FilterActive { all, second, third }
