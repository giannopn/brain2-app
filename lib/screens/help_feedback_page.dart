import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/settings_menu.dart';

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  // Sizing
  static const double _contentTopPadding = 15;
  static const double _contentHorizontalPadding = 15;
  static const double _sectionGap = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar with back button and centered title
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: 'Help & Feedback',
            hideAddButton: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: _contentTopPadding,
                left: _contentHorizontalPadding,
                right: _contentHorizontalPadding,
                bottom: _contentTopPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Help Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Help Title
                      const Padding(
                        padding: EdgeInsets.only(left: 14, top: 4, bottom: 4),
                        child: Text(
                          'Help',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Help Menu Items
                      SettingsMenu(
                        label: 'Getting Started Guide',
                        place: SettingsMenuPlace.upper,
                        icon: SvgPicture.asset(
                          AppIcons.externalLink,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SettingsMenu(
                        label: 'Help Center',
                        place: SettingsMenuPlace.middle,
                        icon: SvgPicture.asset(
                          AppIcons.externalLink,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SettingsMenu(
                        label: 'Contact Support',
                        place: SettingsMenuPlace.lower,
                        icon: SvgPicture.asset(
                          AppIcons.externalLink,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _sectionGap),
                  // Feedback Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Feedback Title
                      const Padding(
                        padding: EdgeInsets.only(left: 14, top: 4, bottom: 4),
                        child: Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Feedback Menu Items
                      SettingsMenu(
                        label: 'Rate Brain 2',
                        place: SettingsMenuPlace.upper,
                        icon: SvgPicture.asset(
                          AppIcons.star,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SettingsMenu(
                        label: 'Share App',
                        place: SettingsMenuPlace.lower,
                        icon: SvgPicture.asset(
                          AppIcons.shareIosExport,
                          width: 24,
                          height: 24,
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
