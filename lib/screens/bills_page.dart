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
import 'package:brain2/screens/add_page.dart';
import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/screens/search_page.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  FilterActive _activeFilter = FilterActive.all;
  List<BillCategory> _allCategories = [];
  List<BillCategory> _filteredCategories = [];
  Map<String, BillStatusType> _categoryStatuses = {};
  int _navIndex = 1; // Library tab active
  bool _showTopBorder = false;
  bool _isLoading = true;
  static double _savedScrollOffset = 0.0;
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _savedScrollOffset,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    if (_scrollController.hasClients) {
      _savedScrollOffset = _scrollController.offset;
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      _savedScrollOffset = _scrollController.offset;
    }
  }

  Future<void> _loadData() async {
    try {
      // Load categories sorted by usage count (highest to lowest)
      final categories = await BillCategoriesRepository.instance
          .fetchCategoriesSortedByUsage();

      // Explicitly sort by usage count (descending) to ensure correct order
      categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
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
        _filterBills();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterBills() {
    List<BillCategory> filtered = List.from(_allCategories);

    // Filter by status based on active filter
    if (_activeFilter == FilterActive.second) {
      // Only pending categories
      filtered = filtered
          .where((cat) => _categoryStatuses[cat.id] == BillStatusType.pending)
          .toList();
    } else if (_activeFilter == FilterActive.third) {
      // Only overdue categories
      filtered = filtered
          .where((cat) => _categoryStatuses[cat.id] == BillStatusType.overdue)
          .toList();
    }
    // If _activeFilter == FilterActive.all, show all categories

    setState(() {
      _filteredCategories = filtered;
    });
  }

  void _onFilterChanged(FilterActive filter) {
    setState(() {
      _activeFilter = filter;
    });
    _filterBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(),
          Container(
            decoration: BoxDecoration(
              border: _showTopBorder
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
                final bool isScrolled = notification.metrics.pixels > 15;
                if (isScrolled != _showTopBorder) {
                  setState(() => _showTopBorder = isScrolled);
                }
                return false;
              },
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCategories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No bills found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await BillCategoriesRepository.instance
                            .fetchCategoriesSortedByUsage(forceRefresh: true);
                        await BillTransactionsRepository.instance
                            .fetchBillTransactions(forceRefresh: true);
                        await _loadData();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filteredCategories.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const SizedBox(height: 4);
                          }
                          if (index == _filteredCategories.length + 1) {
                            return const SizedBox(height: 61);
                          }
                          final category = _filteredCategories[index - 1];
                          final status =
                              _categoryStatuses[category.id] ??
                              BillStatusType.pending;
                          return Column(
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

                                  // Always reload data when returning from category page
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
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return SearchTopBar(
      variant: SearchTopBarVariant.home,
      onAdd: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddPage(source: AddEntrySource.bills),
          ),
        );
      },
      onSearchTap: () {
        Navigator.of(context)
            .push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchPage(),
                transitionDuration: const Duration(milliseconds: 300),
                reverseTransitionDuration: const Duration(milliseconds: 250),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              ),
            )
            .then((result) async {
              if (mounted && result == true) {
                await _loadData();
              }
            });
      },
      width: double.infinity,
    );
  }

  Widget _buildBottomNav() {
    return custom.NavigationBar(
      items: const [
        custom.NavigationBarItem(type: NavigationIconType.home, label: 'Home'),
        custom.NavigationBarItem(
          type: NavigationIconType.library,
          label: 'Library',
        ),
        custom.NavigationBarItem(
          type: NavigationIconType.profile,
          label: 'Profile',
        ),
      ],
      activeIndex: _navIndex,
      onItemSelected: (index) {
        if (index == 0) {
          _savedScrollOffset = _scrollController.hasClients
              ? _scrollController.offset
              : _savedScrollOffset;
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          // Already on library/bills page
          if (_scrollController.hasClients) {
            _scrollController
                .animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                )
                .then((_) {
                  _savedScrollOffset = 0;
                  setState(() => _showTopBorder = false);
                });
          }
        } else if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPage(source: AddEntrySource.bills),
            ),
          );
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
    );
  }
}
