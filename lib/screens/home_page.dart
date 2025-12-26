import 'package:flutter/material.dart';

import 'package:brain2/screens/library_page.dart';
import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/screens/search_page.dart';
import 'package:brain2/screens/bills_page.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/category_title.dart';
import 'package:brain2/widgets/home_page_cards.dart';
import 'package:brain2/widgets/subscriptions_summary.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
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
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HistorySection(horizontalPadding: horizontalPadding),
                      _SubscriptionsSection(
                        horizontalPadding: horizontalPadding,
                      ),
                      const SizedBox(height: 20),
                    ],
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
                    const LibraryPage(),
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
        onAdd: () {},
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
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            CategoryTitle(
              title: 'Past',
              onViewAll: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const BillsPage()));
              },
            ),
            const SizedBox(height: 4),
            const HomePageCard(
              title: 'ΔΕΗ - ΣΠΙΤΙ 2',
              subtitle: '1 day ago',
              subtitleColor: Color(0xFFFF3B30),
              amount: '-34.22€',
              width: double.infinity,
            ),
            const SizedBox(height: 4),
            CategoryTitle(
              title: 'Upcoming',
              onViewAll: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const BillsPage()));
              },
            ),
            const SizedBox(height: 4),
            const HomePageCard(
              title: 'ΔΕΗ',
              subtitle: 'in 6 days',
              amount: '-46.28€',
              width: double.infinity,
            ),
            const SizedBox(height: 4),
            const HomePageCard(
              title: 'ΕΥΔΑΠ',
              subtitle: 'in 10 days',
              amount: '-13.00€',
              width: double.infinity,
            ),
            const SizedBox(height: 4),
            const HomePageCard(
              title: 'INTERNET',
              subtitle: 'in 14 days',
              amount: '-30.90€',
              width: double.infinity,
            ),

            const SizedBox(height: 4),
            const HomePageCard(
              title: 'INTERNET',
              subtitle: 'in 14 days',
              amount: '-30.90€',
              width: double.infinity,
            ),

            const SizedBox(height: 4),
            const HomePageCard(
              title: 'INTERNET',
              subtitle: 'in 14 days',
              amount: '-30.90€',
              width: double.infinity,
            ),

            const SizedBox(height: 4),
            const HomePageCard(
              title: 'INTERNET',
              subtitle: 'in 14 days',
              amount: '-30.90€',
              width: double.infinity,
            ),

            const SizedBox(height: 4),
            const HomePageCard(
              title: 'INTERNET',
              subtitle: 'in 14 days',
              amount: '-30.90€',
              width: double.infinity,
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionsSection extends StatelessWidget {
  const _SubscriptionsSection({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        15,
        horizontalPadding,
        15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTitle(title: 'Subscriptions', onViewAll: () {}),
          const SizedBox(height: 4),
          SubscriptionsSummary(
            width: double.infinity,
            activeCount: 4,
            amount: '-36',
            periodLabel: 'per month',
            indicatorCount: 4,
            indicatorColor: const Color(0xFF2EA39A),
          ),
        ],
      ),
    );
  }
}
