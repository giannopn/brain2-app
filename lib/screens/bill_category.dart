import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:brain2/overlays/delete_confirmation_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/screens/add_page.dart';

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
  ImageProvider? _photo;

  @override
  void initState() {
    super.initState();
    _name = widget.categoryTitle;
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

  Future<void> _addPhoto(BuildContext context) async {
    final selection = await showPhotoAddOverlay(context, title: 'Add photo');

    if (selection == null) return;

    if (selection == 'camera') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opening camera...')));
      // TODO: Integrate camera capture flow
    } else if (selection == 'gallery') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opening gallery...')));
      // TODO: Integrate gallery picker flow
    }

    // Demo: set a local placeholder image to represent the added photo
    setState(() {
      _photo = const AssetImage('assets/icon/brain2_logo.png');
    });
    _resolvePhotoSize(context);
  }

  void _removePhoto() {
    HapticFeedback.selectionClick();
    setState(() {
      _photo = null;
    });
  }

  void _showFullScreenPhoto(BuildContext context) {
    if (_photo == null) return;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: true,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image(image: _photo!),
            ),
          ),
        );
      },
    );
  }

  void _resolvePhotoSize(BuildContext context) {
    final provider = _photo;
    if (provider == null) return;
    final ImageStream stream = provider.resolve(
      createLocalImageConfiguration(context),
    );
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        // Photo size resolved; could be used for sizing if needed
        stream.removeListener(listener);
      },
      onError: (Object _, StackTrace? __) {
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationOverlay(
      context,
      title: 'Delete bill & all transaction history',
      description: 'This action cannot be undone.',
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      // Show confirmation message briefly, then go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill and history deleted'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
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
            onAdd:
                widget.onAdd ??
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddPage()),
                ),
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
                  // Demo image at the top - tap to add/view photo
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _photo == null
                            ? _addPhoto(context)
                            : _showFullScreenPhoto(context),
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
                            child: _photo != null
                                ? Image(image: _photo!, fit: BoxFit.cover)
                                : Image.asset(
                                    AppIcons.billDefaultIcon,
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
                  ),
                  // Remove photo option if photo exists
                  if (_photo != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: GestureDetector(
                          onTap: _removePhoto,
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            'Remove photo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue.shade500,
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
                      onTap: () => _confirmDelete(context),
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
