import 'package:flutter/widgets.dart';

import 'button_small.dart';

class CategoryTitle extends StatelessWidget {
  const CategoryTitle({
    super.key,
    required this.title,
    this.onViewAll,
    this.buttonLabel = 'View all',
    this.width,
  });

  final String title;
  final VoidCallback? onViewAll;
  final String buttonLabel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ButtonSmall(
          label: buttonLabel,
          onPressed: onViewAll,
          variant: ButtonSmallVariant.defaultVariant,
        ),
      ],
    );

    if (width == null) {
      return row;
    }

    return SizedBox(width: width, child: row);
  }
}
