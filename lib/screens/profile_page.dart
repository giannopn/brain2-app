import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brain2/screens/account_page.dart';
import 'package:brain2/screens/about_page.dart';
import 'package:brain2/screens/help_feedback_page.dart';
import 'package:brain2/screens/home_page.dart';
import 'package:brain2/screens/bills_page.dart';
import 'package:brain2/screens/notifications_settings.dart';
import 'package:brain2/overlays/delete_confirmation_swipe.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _navIndex = 2; // Profile tab active
  bool _isSyncing = false;
  String _syncLabel = 'Sync';
  AnimationController? _syncAnimationController;

  String _displayName = '';
  String _email = '';
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _displayName = response['display_name'] ?? 'User';
            _email = response['email'] ?? user.email ?? '';
            _isLoadingProfile = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _displayName = 'User';
          _email = Supabase.instance.client.auth.currentUser?.email ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _syncAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing || _syncAnimationController == null) return;

    setState(() {
      _isSyncing = true;
      _syncLabel = 'Syncing...';
    });

    _syncAnimationController!.repeat();

    await Future.delayed(const Duration(seconds: 2));

    _syncAnimationController!.stop();
    _syncAnimationController!.reset();

    setState(() {
      _isSyncing = false;
      _syncLabel = 'Synced Now';
    });
  }

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
                  child: _isLoadingProfile
                      ? const Center(child: CircularProgressIndicator())
                      : ProfileInfo(
                          name: _displayName,
                          email: _email,
                          isDemoMode: false,
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsSettings(),
                      ),
                    );
                  },
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
                  label: _syncLabel,
                  place: SettingsMenuPlace.lower,
                  icon: _syncAnimationController == null
                      ? SvgPicture.asset(AppIcons.reload, width: 24, height: 24)
                      : AnimatedBuilder(
                          animation: _syncAnimationController!,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle:
                                  _syncAnimationController!.value * 2 * 3.14159,
                              child: SvgPicture.asset(
                                AppIcons.reload,
                                width: 24,
                                height: 24,
                              ),
                            );
                          },
                        ),
                  onTap: _handleSync,
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
                  onTap: () async {
                    final confirmed = await showDeleteConfirmationSwipeOverlay(
                      context,
                      title: 'Log Out?',
                      description: 'Are you sure you want to log out?',
                      confirmText: 'Swipe to confirm',
                    );
                    if (confirmed == true && mounted) {
                      // Log out the user
                      await Supabase.instance.client.auth.signOut();

                      // Pop all routes and return to AuthGate (root)
                      if (mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    }
                  },
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
                    const BillsPage(),
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
