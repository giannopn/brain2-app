import 'package:flutter/material.dart';
import 'package:brain2/widgets/text_top_bar.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/screens/add_new_bill.dart';
import 'package:brain2/screens/create_new_bill_category_page.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/models/bill_category.dart';

enum AddEntrySource { home, bills }

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.source = AddEntrySource.home});

  final AddEntrySource source;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<BillCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToAddNewBill(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewBillPage(
          categoryId: categoryId,
          categoryTitle: categoryName,
          returnTarget: widget.source == AddEntrySource.bills
              ? AddReturnTarget.bills
              : AddReturnTarget.home,
        ),
      ),
    );
  }

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
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_categories.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No bill categories yet.\nCreate one to get started!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._buildCategoryMenuItems(),
                    if (!_isLoading && _categories.isNotEmpty)
                      const SizedBox(height: 15),
                    if (!_isLoading)
                      SettingsMenu(
                        label: 'Create new bill category...',
                        hideIcon: true,
                        rightIcon: SvgPicture.asset(
                          AppIcons.plus,
                          width: 24,
                          height: 24,
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateNewBillCategoryPage(),
                            ),
                          );
                          // Reload categories after returning
                          _loadCategories();
                        },
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryMenuItems() {
    final items = <Widget>[];

    for (int i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final isFirst = i == 0;
      final isLast = i == _categories.length - 1;

      SettingsMenuPlace place;
      if (_categories.length == 1) {
        place = SettingsMenuPlace.defaultPlace;
      } else if (isFirst) {
        place = SettingsMenuPlace.upper;
      } else if (isLast) {
        place = SettingsMenuPlace.lower;
      } else {
        place = SettingsMenuPlace.middle;
      }

      items.add(
        SettingsMenu(
          label: category.title,
          place: place,
          icon: SvgPicture.asset(AppIcons.home, width: 24, height: 24),
          rightIcon: SvgPicture.asset(AppIcons.arrow, width: 24, height: 24),
          onTap: () => _goToAddNewBill(context, category.id, category.title),
        ),
      );

      if (!isLast) {
        items.add(const SizedBox(height: 4));
      }
    }

    return items;
  }
}
