import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/widgets/text_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/widgets/bill_status_menu.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/overlays/success_overlay.dart';
import 'package:brain2/overlays/price_edit.dart';
import 'package:brain2/overlays/calendar_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/overlays/delete_confirmation_overlay.dart';

class AddNewBillPage extends StatefulWidget {
  const AddNewBillPage({
    super.key,
    this.categoryTitle = 'ΔΕΗ',
    this.amount = '-46.28€',
    this.status = BillStatusType.pending,
    this.deadline = '20 Nov 2025',
    this.createdOn = '1 Nov 2025',
    this.onBack,
    this.onMarkAsPaid,
    this.onAddPhoto,
    this.onDelete,
  });

  final String categoryTitle;
  final String amount;
  final BillStatusType status;
  final String deadline;
  final String createdOn;
  final VoidCallback? onBack;
  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onAddPhoto;
  final VoidCallback? onDelete;

  @override
  State<AddNewBillPage> createState() => _AddNewBillPageState();
}

class _AddNewBillPageState extends State<AddNewBillPage> {
  late BillStatusType _status;
  bool _overlayVisible = false;
  late String _amount;
  late String _deadline;
  ImageProvider? _photo;
  Size? _photoSize;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _amount = widget.amount;
    _deadline = widget.deadline;
  }

  Future<void> _editAmount(BuildContext context) async {
    final currentValue = _amount.replaceAll('€', '').trim();

    final updated = await showPriceEditOverlay(
      context,
      title: 'Amount',
      initialValue: currentValue,
      hintText: '',
    );

    if (updated != null && updated.isNotEmpty) {
      final formattedAmount = '${updated}€';
      if (formattedAmount != _amount) {
        setState(() {
          _amount = formattedAmount;
        });
      }
    }
  }

  Future<void> _editDeadline(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(_deadline);
    } catch (e) {
      initialDate = DateTime.now();
    }

    final updated = await showCalendarOverlay(
      context,
      title: 'Deadline',
      initialDate: initialDate,
    );

    if (updated != null) {
      final formatter = _formatDate(updated);
      if (formatter != _deadline) {
        setState(() {
          _deadline = formatter;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

    setState(() {
      _photo = const AssetImage('assets/icon/brain2_logo.png');
    });
    _resolvePhotoSize(context);

    widget.onAddPhoto?.call();
  }

  void _removePhoto() {
    HapticFeedback.selectionClick();
    setState(() {
      _photo = null;
      _photoSize = null;
    });
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
        setState(() {
          _photoSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
        stream.removeListener(listener);
      },
      onError: (Object _, StackTrace? __) {
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationOverlay(
      context,
      title: 'Delete this bill?',
      description: 'This action cannot be undone.',
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
          duration: Duration(seconds: 2),
        ),
      );
      widget.onDelete?.call();
      Navigator.pop(context);
    }
  }

  List<Widget> _buildDetailsChildren(BuildContext context) {
    final widgets = <Widget>[];
    widgets.add(
      Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
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
    );

    widgets.add(
      _status != BillStatusType.paid
          ? GestureDetector(
              onTap: _toggleStatus,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E8D2),
                  borderRadius: BorderRadius.circular(52),
                ),
                child: const Center(
                  child: Text(
                    'Mark as Paid',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    widgets.add(const SizedBox(height: 15));

    widgets.add(
      BillStatusMenu(
        label: 'Status',
        status: _status,
        icon: SvgPicture.asset(AppIcons.mainComponent, width: 24, height: 24),
      ),
    );

    widgets.add(const SizedBox(height: 15));

    widgets.add(
      Column(
        children: [
          SettingsMenu(
            label: 'Amount',
            place: SettingsMenuPlace.upper,
            icon: SvgPicture.asset(AppIcons.tag, width: 24, height: 24),
            rightText: true,
            rightLabel: _amount,
            onRightTap: () => _editAmount(context),
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Deadline',
            place: SettingsMenuPlace.middle,
            icon: SvgPicture.asset(
              AppIcons.calendarEvent,
              width: 24,
              height: 24,
            ),
            rightText: true,
            rightLabel: _deadline,
            onRightTap: () => _editDeadline(context),
          ),
          const SizedBox(height: 4),
          SettingsMenu(
            label: 'Created on',
            place: SettingsMenuPlace.lower,
            icon: SvgPicture.asset(AppIcons.calendar, width: 24, height: 24),
            rightText: true,
            rightLabel: widget.createdOn,
            rightLabelColor: Colors.black,
          ),
        ],
      ),
    );

    widgets.add(const SizedBox(height: 15));

    if (_photo == null) {
      widgets.add(
        SettingsMenu(
          label: 'Photo',
          icon: SvgPicture.asset(AppIcons.image02, width: 24, height: 24),
          rightText: true,
          rightLabel: 'Add photo',
          onRightTap: () => _addPhoto(context),
        ),
      );
    } else {
      widgets.add(
        Column(
          children: [
            SettingsMenu(
              label: 'Photo',
              place: SettingsMenuPlace.upper,
              icon: SvgPicture.asset(AppIcons.image02, width: 24, height: 24),
              rightText: true,
              rightLabel: 'Remove photo',
              onRightTap: _removePhoto,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showFullScreenPhoto(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double aspect =
                          (_photoSize != null &&
                              _photoSize!.width > 0 &&
                              _photoSize!.height > 0)
                          ? _photoSize!.width / _photoSize!.height
                          : 16 / 9;
                      return AspectRatio(
                        aspectRatio: aspect,
                        child: Image(image: _photo!, fit: BoxFit.contain),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    widgets.add(const SizedBox(height: 15));

    if (_status == BillStatusType.paid) {
      widgets.add(
        Column(
          children: [
            SettingsMenu(
              label: 'Mark as unpaid',
              place: SettingsMenuPlace.upper,
              hideIcon: true,
              rightIcon: SvgPicture.asset(
                AppIcons.arrow,
                width: 24,
                height: 24,
              ),
              onTap: _toggleStatus,
            ),
            const SizedBox(height: 4),
            SettingsMenu(
              label: 'Delete this bill',
              place: SettingsMenuPlace.lower,
              hideIcon: true,
              labelColor: const Color(0xFFFF0000),
              rightIcon: SvgPicture.asset(
                AppIcons.arrow,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF0000),
                  BlendMode.srcIn,
                ),
              ),
              onTap: () => _confirmDelete(context),
            ),
          ],
        ),
      );
    } else {
      widgets.add(
        SettingsMenu(
          label: 'Delete this bill',
          hideIcon: true,
          labelColor: const Color(0xFFFF0000),
          rightIcon: SvgPicture.asset(
            AppIcons.arrow,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFFFF0000),
              BlendMode.srcIn,
            ),
          ),
          onTap: () => _confirmDelete(context),
        ),
      );
    }

    widgets.add(const SizedBox(height: 50));

    return widgets;
  }

  void _toggleStatus() {
    if (_status != BillStatusType.paid) {
      HapticFeedback.mediumImpact();
      widget.onMarkAsPaid?.call();
      setState(() {
        _overlayVisible = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _status = BillStatusType.paid;
          _overlayVisible = false;
        });
      });
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _status = BillStatusType.pending;
      });
      widget.onMarkAsPaid?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              TextTopBar(
                variant: TextTopBarVariant.doneInactive,
                title: 'Add new bill',
                onBack: widget.onBack ?? () => Navigator.pop(context),
                onAddPressed: () {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildDetailsChildren(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            opacity: _overlayVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _overlayVisible
                ? const SuccessOverlay()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
