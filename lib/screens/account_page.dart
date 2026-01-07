import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/overlays/text_edit.dart';
import 'package:brain2/overlays/delete_confirmation_swipe.dart';
import 'package:brain2/data/profile_repository.dart';
import 'package:brain2/models/profile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Profile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final cached = ProfileRepository.instance.cachedProfile;
    if (cached != null && mounted) {
      setState(() {
        _profile = cached;
        _isLoading = false;
      });
      return;
    }

    try {
      final fetched = await ProfileRepository.instance.fetchProfile(
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _profile = fetched;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editName(BuildContext context) async {
    if (_profile == null) return;

    final updated = await showTextEditOverlay(
      context,
      title: 'Edit name',
      initialValue: _profile?.displayName ?? '',
      hintText: 'Enter a name',
    );

    if (updated != null &&
        updated.isNotEmpty &&
        updated != _profile?.displayName) {
      setState(() {
        _isSaving = true;
      });

      try {
        final newProfile = await ProfileRepository.instance.updateDisplayName(
          updated,
        );
        if (mounted) {
          setState(() {
            _profile = newProfile ?? _profile;
            _isSaving = false;
          });
          if (newProfile != null) {
            ProfileRepository.instance.setCache(newProfile);
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  // Typography
  static const double _fontSizeLabel = 18;
  static const double _fontSizeValue = 18;
  static const double _fontSizeSignedIn = 18;
  static const double _fontSizeEmail = 14;
  static const double _fontSizeDeleteAccount = 18;

  // Colors
  static const Color _textColor = Color(0xFF000000);
  static const Color _blueColor = Color(0xFF007AFF);
  static const Color _redColor = Color(0xFFE42B2B);
  static const Color _greyTextColor = Color(0xFF6B6B6B);
  static const Color _bgColor = Color(0xFFF1F1F1);

  // Sizing
  static const double _photoSize = 100;
  static const double _contentHorizontalPadding = 15;
  static const double _contentVerticalPadding = 15;
  static const double _sectionGap = 24;
  static const double _menuItemHeight = 52;

  String _getInitials(String name) {
    final letters = name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    if (letters.isEmpty) return '';
    if (letters.length == 1) return letters;
    return letters.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?.displayName ?? '';
    final email = _profile?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar with back button and centered title
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: 'Account',
            hideAddButton: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: _contentVerticalPadding,
                left: _contentHorizontalPadding,
                right: _contentHorizontalPadding,
                bottom: _contentVerticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    // Profile Photo
                    Container(
                      width: _photoSize,
                      height: _photoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _blueColor,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(name),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: _sectionGap),
                    // Name Field
                    Container(
                      width: 400,
                      height: _menuItemHeight,
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(
                                fontSize: _fontSizeLabel,
                                fontWeight: FontWeight.w400,
                                color: _textColor,
                                fontFamily: 'Inter',
                                height: 1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editName(context),
                              child: Text(
                                _isSaving ? 'Saving...' : name,
                                style: TextStyle(
                                  fontSize: _fontSizeValue,
                                  fontWeight: FontWeight.w400,
                                  color: _blueColor,
                                  fontFamily: 'Inter',
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: _sectionGap),
                    // Delete Account Button
                    Container(
                      width: double.infinity,
                      height: _menuItemHeight,
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            final confirmed =
                                await showDeleteConfirmationSwipeOverlay(
                                  context,
                                  title: 'Delete Account?',
                                  description:
                                      'Deleting your account is permanent. You will immediately lose access to all your data. Are you sure?',
                                  confirmText: 'Swipe to confirm',
                                );
                            if (confirmed == true && mounted) {
                              // Show message that deletion is not possible yet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'For security reasons, the deletion of the account inside the app is not possible yet. Please contact us.',
                                  ),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    fontSize: _fontSizeDeleteAccount,
                                    fontWeight: FontWeight.w400,
                                    color: _redColor,
                                    fontFamily: 'Inter',
                                    height: 1,
                                  ),
                                ),
                                SvgPicture.asset(
                                  AppIcons.arrow,
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    _redColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: _sectionGap),
                    // Account Info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Signed in with email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSizeSignedIn,
                            fontWeight: FontWeight.w400,
                            color: _greyTextColor,
                            fontFamily: 'Inter',
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _fontSizeEmail,
                            fontWeight: FontWeight.w400,
                            color: _greyTextColor,
                            fontFamily: 'Inter',
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
