import 'package:flutter/material.dart';

import 'package:brain2/screens/home_page.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/screens/profile_page.dart';
import 'package:brain2/screens/search_page.dart';
import 'package:brain2/screens/add_page.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';
import 'package:brain2/widgets/settings_menu.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          // Top bar with search and add button
          _buildTopBar(),
          // Scrollable content
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
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoriesSection(),
                      const SizedBox(height: 24),
                      _buildItemsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _handleScroll() {
    _savedScrollOffset = _scrollController.offset;
  }

  Widget _buildTopBar() {
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

  Widget _buildCategoriesSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Bills',
            place: SettingsMenuPlace.upper,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Subscriptions',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              'Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΔΕΗ',
            place: SettingsMenuPlace.upper,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΕΥΔΑΠ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΚΟΙΝΟΧΡΗΣΤΑ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΔΕΗ - ΣΠΙΤΙ 2',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'INTERNET',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Youtube Premium',
            place: SettingsMenuPlace.middle,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Cosmote',
            place: SettingsMenuPlace.lower,
            icon: const Icon(
              Icons.credit_card,
              size: 24,
              color: Color(0xFF000000),
            ),
            onTap: () {},
            width: double.infinity,
          ),
        ],
      ),
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
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomePage(),
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
          if (_navIndex == index) {
            // Already on Library: animate scroll to top
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
        }
      },
    );
  }
}
