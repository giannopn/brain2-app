import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/widgets/bill_status_menu.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/overlays/success_overlay.dart';
import 'package:brain2/overlays/price_edit.dart';
import 'package:brain2/overlays/calendar_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';

class BillDetailsPage extends StatefulWidget {
  const BillDetailsPage({
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
  State<BillDetailsPage> createState() => _BillDetailsPageState();
}

class _BillDetailsPageState extends State<BillDetailsPage> {
  late BillStatusType _status;
  bool _overlayVisible = false;
  late String _amount;
  late String _deadline;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _amount = widget.amount;
    _deadline = widget.deadline;
  }

  Future<void> _editAmount(BuildContext context) async {
    // Strip euro symbol for the overlay input
    final currentValue = _amount.replaceAll('€', '').trim();

    final updated = await showPriceEditOverlay(
      context,
      title: 'Amount',
      initialValue: currentValue,
      hintText: '',
    );

    if (updated != null && updated.isNotEmpty) {
      // Append euro symbol to the formatted price
      final formattedAmount = '${updated}€';
      if (formattedAmount != _amount) {
        setState(() {
          _amount = formattedAmount;
        });
      }
    }
  }

  Future<void> _editDeadline(BuildContext context) async {
    // Parse the deadline string to DateTime
    // Expecting format like "20 Nov 2025"
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
      // Format the date back to string "DD MMM YYYY"
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

    widget.onAddPhoto?.call();
  }

  List<Widget> _buildDetailsChildren(BuildContext context) {
    final widgets = <Widget>[];
    // Demo image at the top
    widgets.add(
      Padding(
        padding: const EdgeInsets.all(15),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _addPhoto(context),
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
      ),
    );

    // Toggle control: button for Pending, placeholder for Paid
    widgets.add(
      _status != BillStatusType.paid
          ? GestureDetector(
              onTap: _toggleStatus,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
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

    // Status section
    widgets.add(
      BillStatusMenu(
        label: 'Status',
        status: _status,
        icon: SvgPicture.asset(AppIcons.mainComponent, width: 24, height: 24),
      ),
    );

    widgets.add(const SizedBox(height: 15));

    // Amount, Deadline, Created On sections (grouped)
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

    // Photos section
    widgets.add(
      SettingsMenu(
        label: 'Photo',
        icon: SvgPicture.asset(AppIcons.image02, width: 24, height: 24),
        rightText: true,
        rightLabel: 'Add photo',
        onRightTap: () => _addPhoto(context),
      ),
    );

    widgets.add(const SizedBox(height: 15));

    // Bottom actions: Pending -> single Delete row; Paid -> Mark as unpaid + Delete grouped
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
              onTap: widget.onDelete,
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
          onTap: widget.onDelete,
        ),
      );
    }

    widgets.add(const SizedBox(height: 50));

    return widgets;
  }

  void _toggleStatus() {
    // Toggle behavior: show success overlay only when going Pending -> Paid
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
              SearchTopBar(
                variant: SearchTopBarVariant.withBack,
                centerTitle: widget.categoryTitle,
                onBack: widget.onBack ?? () => Navigator.pop(context),
                paddingTop: 68,
                paddingBottom: 10,
                paddingHorizontal: 15,
                hasText: false,
                width: MediaQuery.of(context).size.width,
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
          // Success overlay layer with fade in/out
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
