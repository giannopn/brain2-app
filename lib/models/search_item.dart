import 'package:flutter/widgets.dart';

enum SearchItemType { bill, subscription }

/// Model for searchable items in the Search page.
/// Contains the title for searching and the widget to render.
class SearchItem {
  const SearchItem({
    required this.title,
    required this.card,
    required this.type,
  });

  /// The title used for search filtering
  final String title;

  /// The card widget to display (BillsCard or HomePageCard)
  final Widget card;

  /// The type of item (bill or subscription)
  final SearchItemType type;
}
