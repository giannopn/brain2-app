import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/filters.dart';
import 'package:brain2/models/search_item.dart';
import 'package:brain2/data/mock_search_data.dart';
import 'package:brain2/screens/bill_category.dart';
import 'package:brain2/screens/add_page.dart';
import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  FilterActive _activeFilter = FilterActive.all;
  List<SearchItem> _filteredBills = [];
  int _navIndex = 1; // Library tab active
  bool _showTopBorder = false;
  static double _savedScrollOffset = 0.0;
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _savedScrollOffset,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _filterBills();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _savedScrollOffset = _scrollController.offset;
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    _savedScrollOffset = _scrollController.offset;
  }

  void _filterBills() {
    // Get only bills from mock data
    List<SearchItem> bills = mockSearchItems
        .where((item) => item.type == SearchItemType.bill)
        .toList();

    // Filter by status based on active filter
    if (_activeFilter == FilterActive.second) {
      // Only pending bills
      bills = bills
          .where(
            (item) =>
                (item.card as dynamic).status.toString() ==
                'BillStatusType.pending',
          )
          .toList();
    } else if (_activeFilter == FilterActive.third) {
      // Only overdue bills
      bills = bills
          .where(
            (item) =>
                (item.card as dynamic).status.toString() ==
                'BillStatusType.overdue',
          )
          .toList();
    }
    // If _activeFilter == FilterActive.all, show all bills

    setState(() {
      _filteredBills = bills;
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
              child: _filteredBills.isEmpty
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
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _filteredBills.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const SizedBox(height: 4);
                        }
                        if (index == _filteredBills.length + 1) {
                          return const SizedBox(height: 61);
                        }
                        final item = _filteredBills[index - 1];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BillCategoryPage(
                                      categoryTitle: item.title,
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: item.card,
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      },
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const AddPage()));
      },
      onSearchTap: () {
        // Handle search tap
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
          _savedScrollOffset = _scrollController.hasClients
              ? _scrollController.offset
              : _savedScrollOffset;
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
