import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/screens/account_page.dart';
import 'package:brain2/screens/about_page.dart';
import 'package:brain2/screens/help_feedback_page.dart';
import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/library_page.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/navigation_bar.dart' as custom;
import 'package:brain2/widgets/navigation_icons.dart';
import 'package:brain2/widgets/profile_info.dart';
import 'package:brain2/widgets/consistency_bar.dart';
import 'package:brain2/widgets/settings_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _navIndex = 2; // Profile tab active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Profile Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ProfileInfo(
                    name: 'Jensen Huang',
                    email: 'jensenhuang@gmail.com',
                    isDemoMode: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Consistency Bar Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ConsistencyBar(consistencyScore: 80),
                ),
                const SizedBox(height: 24),
                // Settings Section Title
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Settings Menu Items - First Group
                SettingsMenu(
                  label: 'Account',
                  place: SettingsMenuPlace.upper,
                  icon: SvgPicture.asset(
                    AppIcons.userCircle,
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                SettingsMenu(
                  label: 'General',
                  place: SettingsMenuPlace.middle,
                  icon: SvgPicture.asset(
                    AppIcons.settings,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 4),
                SettingsMenu(
                  label: 'Notifications',
                  place: SettingsMenuPlace.lower,
                  icon: SvgPicture.asset(
                    AppIcons.notificationBell,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(height: 24),
                // Settings Menu Items - Second Group
                SettingsMenu(
                  label: 'Help & Feedback',
                  place: SettingsMenuPlace.upper,
                  icon: SvgPicture.asset(AppIcons.help, width: 24, height: 24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpFeedbackPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                SettingsMenu(
                  label: 'About',
                  place: SettingsMenuPlace.middle,
                  icon: SvgPicture.asset(AppIcons.info, width: 24, height: 24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                SettingsMenu(
                  label: 'Sync',
                  place: SettingsMenuPlace.lower,
                  icon: SvgPicture.asset(
                    AppIcons.reload,
                    width: 24,
                    height: 24,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Log Out Button
                SettingsMenu(
                  label: 'Log Out',
                  place: SettingsMenuPlace.defaultPlace,
                  labelColor: const Color(0xFFE42B2B),
                  icon: SvgPicture.asset(
                    AppIcons.logOut,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFE42B2B),
                      BlendMode.srcIn,
                    ),
                  ),
                  rightIcon: SvgPicture.asset(
                    AppIcons.arrow,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFE42B2B),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
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
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else if (index == 1) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LibraryPage(),
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
}
