import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/widgets/text_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/widgets/bill_status_menu.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/overlays/success_overlay.dart';
import 'package:brain2/overlays/created_overlay.dart';
import 'package:brain2/overlays/price_edit.dart';
import 'package:brain2/overlays/calendar_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/screens/home_page.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/models/bill_transaction.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddNewBillPage extends StatefulWidget {
  const AddNewBillPage({
    super.key,
    required this.categoryId,
    this.categoryTitle = 'Bill',
    this.amount = '0.00€',
    this.status = BillStatusType.pending,
    this.deadline = '20 Nov 2025',
    this.createdOn = '1 Nov 2025',
    this.onBack,
    this.onMarkAsPaid,
    this.onAddPhoto,
    this.onDelete,
  });

  final String categoryId;
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
  bool _createdOverlayVisible = false;
  late String _amount;
  late String _deadline;
  late DateTime _deadlineDate;
  late String _createdOn;
  ImageProvider? _photo;
  Size? _photoSize;
  bool _hasInitializedFlow = false;
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _uploadedReceiptPath;

  @override
  void initState() {
    super.initState();
    _status = widget.status;

    // Set amount to 0.00€
    _amount = '0.00€';

    // Set deadline to one day after today
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _deadlineDate = tomorrow;
    _deadline = _formatDate(tomorrow);

    // Set created on to today
    final today = DateTime.now();
    _createdOn = _formatDate(today);

    // Start initial flow on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitializedFlow) {
        _hasInitializedFlow = true;
        _startInitialFlow();
      }
    });
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
    DateTime initialDate = _deadlineDate;

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
          _deadlineDate = updated;
          _updateStatusBasedOnDeadline();
        });
      }
    }
  }

  void _updateStatusBasedOnDeadline() {
    if (_status != BillStatusType.paid) {
      if (_deadlineDate.isBefore(DateTime.now())) {
        _status = BillStatusType.overdue;
      } else {
        _status = BillStatusType.pending;
      }
    }
  }

  void _forceUpdateStatusBasedOnDeadline() {
    if (_deadlineDate.isBefore(DateTime.now())) {
      _status = BillStatusType.overdue;
    } else {
      _status = BillStatusType.pending;
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

  Future<void> _startInitialFlow() async {
    // Step 1: Prompt for amount
    await _editAmountInitial(context);
  }

  Future<void> _editAmountInitial(BuildContext context) async {
    final currentValue = _amount.replaceAll('€', '').trim();

    // If amount is 0.00, start with empty field for easier input
    final initialValue = currentValue == '0.00' ? '' : currentValue;

    final updated = await showPriceEditOverlay(
      context,
      title: 'Amount',
      initialValue: initialValue,
      hintText: '',
    );

    if (updated != null && updated.isNotEmpty) {
      final formattedAmount = '${updated}€';
      setState(() {
        _amount = formattedAmount;
      });
      // Step 2: After amount is set, prompt for deadline
      await _editDeadlineInitial(context);
    }
  }

  Future<void> _editDeadlineInitial(BuildContext context) async {
    DateTime initialDate = _deadlineDate;

    final updated = await showCalendarOverlay(
      context,
      title: 'Deadline',
      initialDate: initialDate,
    );

    if (updated != null) {
      final formatter = _formatDate(updated);
      setState(() {
        _deadline = formatter;
        _deadlineDate = updated;
        _updateStatusBasedOnDeadline();
      });
      // Initial flow complete
    }
  }

  Future<void> _addPhoto(BuildContext context) async {
    final selection = await showPhotoAddOverlay(context, title: 'Add photo');

    if (selection == null) return;

    if (selection == 'camera') {
      await _pickFromCamera(context);
    } else if (selection == 'gallery') {
      await _pickFromGallery(context);
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (picked == null) return;

      if (!mounted) return;
      setState(() {
        _photo = FileImage(File(picked.path));
      });
      _resolvePhotoSize(context);
      _uploadedReceiptPath = await _uploadReceipt(picked.path);
      widget.onAddPhoto?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not capture photo: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (picked == null) return;

      if (!mounted) return;
      setState(() {
        _photo = FileImage(File(picked.path));
      });
      _resolvePhotoSize(context);
      _uploadedReceiptPath = await _uploadReceipt(picked.path);
      widget.onAddPhoto?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load photo: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> _uploadReceipt(String localPath) async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload.')),
        );
        return null;
      }

      final file = File(localPath);
      final ext = localPath.split('.').last.toLowerCase();
      final mime = _mimeFromExt(ext);
      final filename = 'new_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final key = '${user.id}/pending/$filename';

      final bytes = await file.readAsBytes();
      await client.storage
          .from('receipts')
          .uploadBinary(
            key,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mime),
          );
      return key;
    } on StorageException catch (se) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: ${se.message}')));
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  String _mimeFromExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _removePhoto() async {
    HapticFeedback.selectionClick();

    final uploadedPath = _uploadedReceiptPath;

    // Clear local state immediately for responsive UI
    setState(() {
      _photo = null;
      _photoSize = null;
      _uploadedReceiptPath = null;
    });

    // Delete from storage if it was uploaded
    if (uploadedPath != null && uploadedPath.isNotEmpty) {
      try {
        final client = Supabase.instance.client;
        await client.storage.from('receipts').remove([uploadedPath]);
      } catch (e) {
        // Show error if deletion fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove photo: ${e.toString()}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
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
            child: Image.asset(
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
    );

    widgets.add(const SizedBox(height: 0));

    // Bill name title
    widgets.add(
      Text(
        widget.categoryTitle,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );

    widgets.add(const SizedBox(height: 15));

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
            rightLabel: _createdOn,
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
        SettingsMenu(
          label: 'Mark as unpaid',
          hideIcon: true,
          rightIcon: SvgPicture.asset(AppIcons.arrow, width: 24, height: 24),
          onTap: _toggleStatus,
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
        // Re-evaluate status based on deadline when marking as unpaid
        _forceUpdateStatusBasedOnDeadline();
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
                variant: TextTopBarVariant.defaultActive,
                title: 'Add new bill',
                onBack: widget.onBack ?? () => Navigator.pop(context),
                onAddPressed: _handleCreateTransaction,
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
          AnimatedOpacity(
            opacity: _createdOverlayVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _createdOverlayVisible
                ? const CreatedOverlay()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  model.BillStatus _mapBillStatus(BillStatusType type) {
    switch (type) {
      case BillStatusType.paid:
        return model.BillStatus.paid;
      case BillStatusType.overdue:
        return model.BillStatus.overdue;
      case BillStatusType.pending:
        return model.BillStatus.pending;
    }
  }

  double _parseAmount(String amountStr) {
    final cleaned = amountStr.replaceAll('€', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  Future<void> _handleCreateTransaction() async {
    if (_isSaving || _createdOverlayVisible) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add a bill.')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final amount = _parseAmount(_amount);

      await BillTransactionsRepository.instance.createBillTransaction(
        categoryId: widget.categoryId,
        amount: amount,
        dueDate: _deadlineDate,
        status: _mapBillStatus(_status),
        receiptUrl: _uploadedReceiptPath,
      );

      if (!mounted) return;

      HapticFeedback.mediumImpact();
      setState(() {
        _createdOverlayVisible = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      final message = error is PostgrestException && error.message.isNotEmpty
          ? error.message
          : 'Failed to create bill. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
