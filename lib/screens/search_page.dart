import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/filters.dart';
import 'package:brain2/models/search_item.dart';
import 'package:brain2/data/mock_search_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasText = false;
  bool _showFiltersBorder = false;
  FilterActive _activeFilter = FilterActive.all;
  List<SearchItem> _filteredItems = mockSearchItems;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _hasText = _searchController.text.isNotEmpty;
      _filterItems();
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();

    List<SearchItem> items = mockSearchItems;

    // Filter by type based on active filter
    if (_activeFilter == FilterActive.second) {
      // Only bills
      items = items.where((item) => item.type == SearchItemType.bill).toList();
    } else if (_activeFilter == FilterActive.third) {
      // Only subscriptions
      items = items
          .where((item) => item.type == SearchItemType.subscription)
          .toList();
    }
    // If _activeFilter == FilterActive.all, show all types

    // Filter by search query
    if (query.isNotEmpty) {
      items = items
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();

      // Sort results by relevance score (descending), then alphabetically
      items.sort((a, b) {
        final scoreA = _calculateRelevanceScore(a.title, query);
        final scoreB = _calculateRelevanceScore(b.title, query);

        // Higher score first (descending)
        if (scoreA != scoreB) {
          return scoreB.compareTo(scoreA);
        }

        // Tie-breaker: alphabetical order
        return a.title.compareTo(b.title);
      });
    }

    _filteredItems = items;
  }

  void _onFilterChanged(FilterActive filter) {
    setState(() {
      _activeFilter = filter;
      _filterItems(); // Re-filter items when filter changes
    });
    _searchFocusNode.unfocus();
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  /// Calculates relevance score for a search result.
  /// Higher score = more relevant, appears first in results.
  ///
  /// Scoring rules (highest priority first):
  /// - Exact match: 1000
  /// - Title starts with query: 500 + (1000 - matchPosition)
  /// - Any word starts with query: 300 + (1000 - matchPosition)
  /// - Contains query: 100 + (1000 - matchPosition)
  double _calculateRelevanceScore(String title, String query) {
    final normalizedTitle = title.toLowerCase();
    final matchPosition = normalizedTitle.indexOf(query);

    // Exact match
    if (normalizedTitle == query) {
      return 1000.0;
    }

    // Title starts with query
    if (normalizedTitle.startsWith(query)) {
      return 500.0 + (1000 - matchPosition);
    }

    // Any word in title starts with query
    final words = normalizedTitle.split(RegExp(r'\s+'));
    for (final word in words) {
      if (word.startsWith(query)) {
        return 300.0 + (1000 - matchPosition);
      }
    }

    // Contains query anywhere
    if (matchPosition != -1) {
      return 100.0 + (1000 - matchPosition);
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Column(
          children: [
            SearchTopBar(
              variant: SearchTopBarVariant.searchMode,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              hasText: _hasText,
              onAdd: () => Navigator.of(context).pop(),
              onClear: () {
                _searchController.clear();
              },
              onSearchChanged: (value) {
                // Handle search logic here if needed
              },
              width: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                border: _showFiltersBorder
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 4),
                child: Filters(
                  labelSecond: 'Bills',
                  labelThird: 'Subscriptions',
                  active: _activeFilter,
                  onChanged: _onFilterChanged,
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _dismissKeyboard();
                  }
                  final bool isScrolled = notification.metrics.pixels > 0;
                  if (isScrolled != _showFiltersBorder) {
                    setState(() => _showFiltersBorder = isScrolled);
                  }
                  return false;
                },
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _filteredItems.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const SizedBox(height: 4);
                          }
                          if (index == _filteredItems.length + 1) {
                            return const SizedBox(height: 61);
                          }
                          final item = _filteredItems[index - 1];
                          return Column(
                            children: [item.card, const SizedBox(height: 4)],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
