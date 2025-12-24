import 'package:flutter/material.dart';

import 'package:brain2/screens/library_page.dart';
import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/screens/search_page.dart';
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

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistorySection(horizontalPadding: horizontalPadding),
                    _SubscriptionsSection(horizontalPadding: horizontalPadding),
                    const SizedBox(height: 20),
                  ],
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
          if (index == 1) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LibraryPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ProfilePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            setState(() => _navIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SearchTopBar(
      variant: SearchTopBarVariant.home,
      onAdd: () {},
      onSearchTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SearchPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      width: double.infinity,
    );
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
            CategoryTitle(title: 'Past', onViewAll: () {}),
            const SizedBox(height: 4),
            const HomePageCard(
              title: 'ΔΕΗ - ΣΠΙΤΙ 2',
              subtitle: '1 day ago',
              subtitleColor: Color(0xFFFF3B30),
              amount: '-34.22€',
              width: double.infinity,
            ),
            const SizedBox(height: 4),
            CategoryTitle(title: 'Upcoming', onViewAll: () {}),
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
