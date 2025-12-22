import 'package:flutter/material.dart';

import 'package:brain2/screens/home_page.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/screens/profile_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top bar with search and add button
          _buildTopBar(),
          // Scrollable content
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),
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
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildBottomNav(), const SizedBox(height: 50)],
      ),
    );
  }

  Widget _buildTopBar() {
    return SearchTopBar(
      variant: SearchTopBarVariant.home,
      onAdd: () {},
      width: double.infinity,
    );
  }

  Widget _buildCategoriesSection() {
    return SizedBox(
      width: 390,
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
            width: 390,
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
            width: 390,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return SizedBox(
      width: 390,
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
            width: 390,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΕΥΔΑΠ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: 390,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΚΟΙΝΟΧΡΗΣΤΑ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: 390,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: 390,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'ΔΕΗ - ΣΠΙΤΙ 2',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: 390,
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'INTERNET',
            place: SettingsMenuPlace.middle,
            icon: const Icon(Icons.home, size: 24, color: Color(0xFF000000)),
            onTap: () {},
            width: 390,
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
            width: 390,
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
            width: 390,
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
            width: 390,
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
            width: 390,
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
          svgAssetPath: 'assets/svg_icons/Icons/Library.svg',
          label: 'Library',
        ),
        custom.NavigationBarItem(
          svgAssetPath: 'assets/svg_icons/Icons/User_Circle.svg',
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
          setState(() => _navIndex = index);
        }
      },
    );
  }
}
