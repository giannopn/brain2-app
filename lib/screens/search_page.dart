import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/filters.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/models/bill_category.dart';
import 'package:brain2/models/bill_transaction.dart' as model;
import 'package:brain2/screens/bill_category.dart';

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
  List<BillCategory> _allCategories = [];
  List<BillCategory> _filteredItems = [];
  Map<String, BillStatusType> _categoryStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load categories from cache
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();

      // Load all transactions to determine status for each category
      final transactions = await BillTransactionsRepository.instance
          .fetchBillTransactions();

      // Calculate status for each category based on its transactions
      final Map<String, BillStatusType> statuses = {};
      for (final category in categories) {
        final categoryTransactions = transactions
            .where((t) => t.categoryId == category.id)
            .toList();

        if (categoryTransactions.isEmpty) {
          // No transactions yet, default to paid
          statuses[category.id] = BillStatusType.paid;
        } else {
          // Check if any transaction is overdue
          final hasOverdue = categoryTransactions.any(
            (t) => t.status == model.BillStatus.overdue,
          );
          if (hasOverdue) {
            statuses[category.id] = BillStatusType.overdue;
          } else {
            // Check if any transaction is pending
            final hasPending = categoryTransactions.any(
              (t) => t.status == model.BillStatus.pending,
            );
            if (hasPending) {
              statuses[category.id] = BillStatusType.pending;
            } else {
              // All transactions are paid
              statuses[category.id] = BillStatusType.paid;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _allCategories = categories;
          _categoryStatuses = statuses;
          _isLoading = false;
        });
        _filterItems();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _hasText = _searchController.text.isNotEmpty;
      _filterItems();
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();

    List<BillCategory> items = List.from(_allCategories);

    // Filter by status based on active filter
    if (_activeFilter == FilterActive.second) {
      // Only pending categories
      items = items
          .where((cat) => _categoryStatuses[cat.id] == BillStatusType.pending)
          .toList();
    } else if (_activeFilter == FilterActive.third) {
      // Only overdue categories
      items = items
          .where((cat) => _categoryStatuses[cat.id] == BillStatusType.overdue)
          .toList();
    }
    // If _activeFilter == FilterActive.all, show all categories

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

    setState(() {
      _filteredItems = items;
    });
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
              onAdd: () => Navigator.of(context).pop(true),
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
                  labelAll: 'All',
                  labelSecond: 'Pending',
                  labelThird: 'Overdue',
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredItems.isEmpty
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
                          final category = _filteredItems[index - 1];
                          final status =
                              _categoryStatuses[category.id] ??
                              BillStatusType.pending;
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(category.id),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BillCategoryPage(
                                          categoryId: category.id,
                                          categoryTitle: category.title,
                                        ),
                                      ),
                                    );

                                    // Reload data when returning from category page
                                    if (mounted) {
                                      await _loadData();
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: BillsCard(
                                    type: BillsCardType.general,
                                    title: category.title,
                                    status: status,
                                    width: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
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
