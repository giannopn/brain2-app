import 'package:flutter/widgets.dart';

import 'button_small.dart';

/// Filters widget based on Figma component (node 1058:7902).
///
/// Shows three small pill buttons: "All", "Pending", "Overdue".
/// The active button is rendered with a black background and light text,
/// matching the existing `ButtonSmall` styles.
class Filters extends StatelessWidget {
  const Filters({super.key, this.active = FilterActive.all, this.onChanged});

  /// Which filter is currently active.
  final FilterActive active;

  /// Called when a filter button is tapped.
  final ValueChanged<FilterActive>? onChanged;

  @override
  Widget build(BuildContext context) {
    ButtonSmall _buildButton(String label, FilterActive value) {
      final isActive = active == value;
      return ButtonSmall(
        label: label,
        variant: isActive
            ? ButtonSmallVariant.active
            : ButtonSmallVariant.defaultVariant,
        onPressed: onChanged == null ? null : () => onChanged!(value),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildButton('All', FilterActive.all),
        const SizedBox(width: 10),
        _buildButton('Pending', FilterActive.pending),
        const SizedBox(width: 10),
        _buildButton('Overdue', FilterActive.overdue),
      ],
    );
  }
}

/// Variants for the active button state.
/// Mirrors Figma property: Active Button = All | Pending | Overdue.
enum FilterActive { all, pending, overdue }
