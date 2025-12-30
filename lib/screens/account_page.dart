import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/overlays/text_edit.dart';
import 'package:brain2/overlays/delete_confirmation_swipe.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = 'Jensen Huang';
  }

  Future<void> _editName(BuildContext context) async {
    final updated = await showTextEditOverlay(
      context,
      title: 'Edit name',
      initialValue: _name,
      hintText: 'Enter a name',
    );

    if (updated != null && updated.isNotEmpty && updated != _name) {
      setState(() {
        _name = updated;
      });
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

  @override
  Widget build(BuildContext context) {
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
                        'JH',
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
                              _name,
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
                            // Perform delete account action
                            Navigator.of(context).pop();
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
                        'Signed in with Apple Account',
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
                        'jensenhuang@gmail.com',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
