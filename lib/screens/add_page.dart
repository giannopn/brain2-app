import 'package:flutter/material.dart';
import 'package:brain2/widgets/text_top_bar.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/screens/create_new_bill_category_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TextTopBar(
            variant: TextTopBarVariant.defaultActive,
            title: 'Add new bill',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    // Grouped preset items
                    SettingsMenu(
                      label: 'ΔΕΗ',
                      place: SettingsMenuPlace.upper,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    SettingsMenu(
                      label: 'ΕΥΔΑΠ',
                      place: SettingsMenuPlace.middle,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    SettingsMenu(
                      label: 'ΚΟΙΝΟΧΡΗΣΤΑ',
                      place: SettingsMenuPlace.middle,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    SettingsMenu(
                      label: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
                      place: SettingsMenuPlace.middle,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    SettingsMenu(
                      label: 'ΔΕΗ - ΣΠΙΤΙ 2',
                      place: SettingsMenuPlace.middle,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 4),
                    SettingsMenu(
                      label: 'INTERNET',
                      place: SettingsMenuPlace.lower,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      rightIcon: SvgPicture.asset(
                        AppIcons.arrow,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 15),

                    // Add new item row
                    SettingsMenu(
                      label: 'Create new bill category...',
                      hideIcon: true,
                      rightIcon: SvgPicture.asset(
                        AppIcons.plus,
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CreateNewBillCategoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
