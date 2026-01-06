import 'package:flutter/material.dart';

import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/screens/search_page.dart';
import 'package:brain2/screens/bills_page.dart';
import 'package:brain2/screens/add_page.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/category_title.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/screens/bill_details_page.dart';
import 'package:brain2/models/bill_transaction.dart' as model;
import 'package:brain2/widgets/bill_status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  bool _showTopBorder = false;
  static double _savedScrollOffset = 0.0;
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: _savedScrollOffset,
  );

  // Data for Past/Upcoming
  List<model.BillTransaction> _pastTransactions = [];
  List<model.BillTransaction> _upcomingTransactions = [];
  Map<String, String> _categoryTitles = {};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _savedScrollOffset = _scrollController.offset;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final bool isScrolled = notification.metrics.pixels > 15;
                if (isScrolled != _showTopBorder) {
                  setState(() => _showTopBorder = isScrolled);
                }
                return false;
              },
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        CategoryTitle(
                          title: 'Past',
                          onViewAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BillsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        if (_isLoadingData)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_pastTransactions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No past bills',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        else
                          ..._buildTransactionCards(_pastTransactions),

                        const SizedBox(height: 12),
                        CategoryTitle(
                          title: 'Upcoming',
                          onViewAll: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BillsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        if (_isLoadingData)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_upcomingTransactions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No upcoming bills',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        else
                          ..._buildTransactionCards(_upcomingTransactions),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: custom.NavigationBar(
        items: const [
          custom.NavigationBarItem(
            type: NavigationIconType.home,
            label: 'Home',
          ),
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
            if (_navIndex == index) {
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
            } else {
              setState(() => _navIndex = index);
            }
          } else if (index == 1) {
            _savedScrollOffset = _scrollController.hasClients
                ? _scrollController.offset
                : _savedScrollOffset;
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const BillsPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
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
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: _showTopBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
              )
            : null,
      ),
      child: SearchTopBar(
        variant: SearchTopBarVariant.home,
        onAdd: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddPage()));
        },
        onSearchTap: () {
          Navigator.of(context).push(
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
          );
        },
        width: double.infinity,
      ),
    );
  }

  void _handleScroll() {
    _savedScrollOffset = _scrollController.offset;
  }

  Future<void> _loadData() async {
    try {
      // Load categories for title lookup
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();
      final titles = <String, String>{
        for (final c in categories) c.id: c.title,
      };

      // Load transactions (cache-first)
      final all = await BillTransactionsRepository.instance
          .fetchBillTransactions();

      final now = DateTime.now();
      DateTime dOnly(DateTime d) => DateTime(d.year, d.month, d.day);
      final today = dOnly(now);

      final past =
          all
              .where(
                (t) =>
                    t.status != model.BillStatus.paid &&
                    dOnly(t.dueDate).isBefore(today),
              )
              .toList()
            ..sort(
              (a, b) => a.dueDate.compareTo(b.dueDate),
            ); // oldest -> most recent

      final upcoming =
          all.where((t) => !dOnly(t.dueDate).isBefore(today)).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate)); // nearest -> far

      if (!mounted) return;
      setState(() {
        _categoryTitles = titles;
        _pastTransactions = past;
        _upcomingTransactions = upcoming;
        _isLoadingData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  String _formatDeadline(DateTime dueDate, model.BillStatus status) {
    final today = DateTime.now();
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysDiff = dateOnly.difference(todayOnly).inDays;

    if (daysDiff == 0) return 'Today';
    if (daysDiff == 1) return 'Tomorrow';
    if (daysDiff > 1) return 'in $daysDiff days';

    if (daysDiff == -1 && status != model.BillStatus.paid) return 'yesterday';
    if (daysDiff < 0 && status != model.BillStatus.paid)
      return '${-daysDiff} days ago';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
  }

  BillStatusType _mapTransactionStatus(model.BillStatus status) {
    switch (status) {
      case model.BillStatus.paid:
        return BillStatusType.paid;
      case model.BillStatus.pending:
        return BillStatusType.pending;
      case model.BillStatus.overdue:
        return BillStatusType.overdue;
    }
  }

  List<Widget> _buildTransactionCards(List<model.BillTransaction> list) {
    final widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      final t = list[i];
      final title = _categoryTitles[t.categoryId] ?? 'Bill';
      final subtitle = _formatDeadline(t.dueDate, t.status);
      final amount = '${t.amount.toStringAsFixed(2)}€';
      final status = _mapTransactionStatus(t.status);

      widgets.add(
        BillsCard(
          type: BillsCardType.detailed,
          title: title,
          subtitle: subtitle,
          amount: amount,
          status: status,
          width: double.infinity,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillDetailsPage(transactionId: t.id),
              ),
            );
            if (mounted) await _loadData();
          },
        ),
      );
      if (i < list.length - 1) widgets.add(const SizedBox(height: 4));
    }
    return widgets;
  }
}
