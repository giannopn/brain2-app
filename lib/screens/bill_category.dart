import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/category_title.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/screens/bill_transactions_page.dart';
import 'package:brain2/screens/bill_details_page.dart';
import 'package:brain2/overlays/text_edit.dart';

class BillCategoryPage extends StatefulWidget {
  const BillCategoryPage({
    super.key,
    this.categoryTitle = 'ΔΕΗ',
    this.onBack,
    this.onAdd,
  });

  final String categoryTitle;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;

  @override
  State<BillCategoryPage> createState() => _BillCategoryPageState();
}

class _BillCategoryPageState extends State<BillCategoryPage> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.categoryTitle;
  }

  Future<void> _editName(BuildContext context) async {
    final updated = await showTextEditOverlay(
      context,
      title: 'Name',
      initialValue: _name,
      hintText: 'Enter a name',
    );

    if (updated != null && updated.isNotEmpty && updated != _name) {
      setState(() {
        _name = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: _name,
            onBack: widget.onBack ?? () => Navigator.pop(context),
            onAdd: widget.onAdd,
            paddingTop: 68,
            paddingBottom: 10,
            paddingHorizontal: 15,
            hasText: false,
            width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demo image at the top
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://via.placeholder.com/100',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Name and Category info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SettingsMenu(
                      label: 'Name',
                      rightText: true,
                      rightLabel: _name,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      place: SettingsMenuPlace.defaultPlace,
                      onRightTap: () => _editName(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bills Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CategoryTitle(
                      title: 'Transactions',
                      buttonLabel: 'View all',
                      onViewAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BillTransactionsPage(categoryTitle: _name),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bill items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        BillsCard(
                          type: BillsCardType.detailed,
                          title: _name,
                          subtitle: 'in 6 days',
                          amount: '-46.28€',
                          status: BillStatusType.pending,
                          width: double.infinity,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                  categoryTitle: _name,
                                  amount: '-46.28€',
                                  status: BillStatusType.pending,
                                  deadline: 'in 6 days',
                                  createdOn: '1 Nov 2025',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.detailed,
                          title: _name,
                          subtitle: '17 November 2025',
                          amount: '-34.76€',
                          status: BillStatusType.paid,
                          width: double.infinity,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                  categoryTitle: _name,
                                  amount: '-34.76€',
                                  status: BillStatusType.paid,
                                  deadline: '17 November 2025',
                                  createdOn: '1 Nov 2025',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.detailed,
                          title: _name,
                          subtitle: '6 October 2025',
                          amount: '-37.58€',
                          status: BillStatusType.paid,
                          width: double.infinity,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                  categoryTitle: _name,
                                  amount: '-37.58€',
                                  status: BillStatusType.paid,
                                  deadline: '6 October 2025',
                                  createdOn: '1 Nov 2025',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.detailed,
                          title: _name,
                          subtitle: '4 September 2025',
                          amount: '-32.14€',
                          status: BillStatusType.paid,
                          width: double.infinity,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                  categoryTitle: _name,
                                  amount: '-32.14€',
                                  status: BillStatusType.paid,
                                  deadline: '4 September 2025',
                                  createdOn: '1 Nov 2025',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.detailed,
                          title: _name,
                          subtitle: '4 August 2025',
                          amount: '-65.31€',
                          status: BillStatusType.paid,
                          width: double.infinity,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsPage(
                                  categoryTitle: _name,
                                  amount: '-65.31€',
                                  status: BillStatusType.paid,
                                  deadline: '4 August 2025',
                                  createdOn: '1 Nov 2025',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Delete button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {
                        // Handle delete action
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Delete $_name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFF0000),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SvgPicture.asset(
                              AppIcons.arrow,
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFFF0000),
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
