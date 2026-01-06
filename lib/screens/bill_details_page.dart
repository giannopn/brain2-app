import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:brain2/widgets/bill_status_menu.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/overlays/success_overlay.dart';
import 'package:brain2/overlays/price_edit.dart';
import 'package:brain2/overlays/calendar_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/overlays/delete_confirmation_overlay.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/models/bill_transaction.dart' as model;

class BillDetailsPage extends StatefulWidget {
  const BillDetailsPage({
    super.key,
    required this.transactionId,
    this.onBack,
    this.onMarkAsPaid,
    this.onAddPhoto,
    this.onDelete,
  });

  final String transactionId;
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
  late DateTime _deadlineDate;
  String _createdOn = '';
  String _categoryTitle = 'Bill';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  ImageProvider? _photo;
  Size? _photoSize;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _status = BillStatusType.pending;
    _amount = '0€';
    _deadline = '';
    _deadlineDate = DateTime.now();

    _loadTransaction();
  }

  Future<void> _editAmount(BuildContext context) async {
    if (_isSaving) return;

    // Strip euro symbol for the overlay input
    final currentValue = _amount.replaceAll('€', '').trim();

    final updated = await showPriceEditOverlay(
      context,
      title: 'Amount',
      initialValue: currentValue,
      hintText: '',
    );

    if (updated != null && updated.isNotEmpty) {
      final parsed = double.tryParse(updated.replaceAll(',', '.'));
      if (parsed != null) {
        if (mounted) {
          await _updateTransactionOnServer(amount: parsed);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid amount'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _editDeadline(BuildContext context) async {
    if (_isSaving) return;
    // Use the _deadlineDate if available, otherwise try to parse _deadline
    DateTime initialDate = _deadlineDate;

    final updated = await showCalendarOverlay(
      context,
      title: 'Deadline',
      initialDate: initialDate,
    );

    if (updated != null) {
      // Determine new status if not paid
      BillStatusType newStatus = _status;
      if (_status != BillStatusType.paid) {
        newStatus = updated.isBefore(DateTime.now())
            ? BillStatusType.overdue
            : BillStatusType.pending;
      }

      await _updateTransactionOnServer(dueDate: updated, status: newStatus);
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

  BillStatusType _mapModelStatus(model.BillStatus status) {
    switch (status) {
      case model.BillStatus.paid:
        return BillStatusType.paid;
      case model.BillStatus.pending:
        return BillStatusType.pending;
      case model.BillStatus.overdue:
        return BillStatusType.overdue;
    }
  }

  model.BillStatus _mapToModelStatus(BillStatusType status) {
    switch (status) {
      case BillStatusType.paid:
        return model.BillStatus.paid;
      case BillStatusType.pending:
        return model.BillStatus.pending;
      case BillStatusType.overdue:
        return model.BillStatus.overdue;
    }
  }

  void _applyTransaction(model.BillTransaction tx, String categoryTitle) {
    _status = _mapModelStatus(tx.status);
    _amount = '${tx.amount.toStringAsFixed(2)}€';
    _deadlineDate = tx.dueDate;
    _deadline = _formatDate(tx.dueDate);
    _createdOn = _formatDate(tx.createdAt);
    _categoryTitle = categoryTitle;

    // Load receipt image if available
    if (tx.receiptUrl != null && tx.receiptUrl!.isNotEmpty) {
      _loadReceiptImage(tx.receiptUrl!);
    }
  }

  Future<void> _updateTransactionOnServer({
    double? amount,
    DateTime? dueDate,
    BillStatusType? status,
  }) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final updated = await BillTransactionsRepository.instance
          .updateBillTransaction(
            id: widget.transactionId,
            amount: amount,
            dueDate: dueDate,
            status: status != null ? _mapToModelStatus(status) : null,
          );

      String categoryTitle = _categoryTitle;
      try {
        final categories = await BillCategoriesRepository.instance
            .fetchBillCategories();
        final match = categories.where((c) => c.id == updated.categoryId);
        if (match.isNotEmpty) {
          categoryTitle = match.first.title;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _applyTransaction(updated, categoryTitle);
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _loadTransaction() async {
    model.BillTransaction? tx;

    final cached = BillTransactionsRepository.instance.cachedTransactions;
    if (cached != null) {
      try {
        tx = cached.firstWhere((t) => t.id == widget.transactionId);
      } catch (_) {}
    }

    if (tx == null) {
      final fetched = await BillTransactionsRepository.instance
          .fetchBillTransactions();
      try {
        tx = fetched.firstWhere((t) => t.id == widget.transactionId);
      } catch (_) {}
    }

    if (tx == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction not found'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    String categoryTitle = _categoryTitle;
    try {
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();
      final match = categories.where((c) => c.id == tx!.categoryId);
      if (match.isNotEmpty) {
        categoryTitle = match.first.title;
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _applyTransaction(tx!, categoryTitle);
      _isLoading = false;
    });
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
      final receiptKey = await _uploadReceiptAndSave(picked.path);
      if (receiptKey != null) {
        widget.onAddPhoto?.call();
      }
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
      final receiptKey = await _uploadReceiptAndSave(picked.path);
      if (receiptKey != null) {
        widget.onAddPhoto?.call();
      }
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

  Future<String?> _uploadReceiptAndSave(String localPath) async {
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
      final filename =
          '${widget.transactionId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final key = '${user.id}/${widget.transactionId}/$filename';

      final bytes = await file.readAsBytes();
      await client.storage
          .from('receipts')
          .uploadBinary(
            key,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mime),
          );

      // Persist key to transaction
      await BillTransactionsRepository.instance.updateBillTransaction(
        id: widget.transactionId,
        receiptUrl: key,
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

  Future<void> _loadReceiptImage(String storageKey) async {
    try {
      final client = Supabase.instance.client;
      final signedUrl = await client.storage
          .from('receipts')
          .createSignedUrl(storageKey, 3600); // 1 hour validity

      if (mounted) {
        setState(() {
          _photo = NetworkImage(signedUrl);
        });
        _resolvePhotoSize(context);
      }
    } catch (e) {
      // Silently fail if image can't be loaded (e.g., deleted from storage)
      if (mounted) {
        setState(() {
          _photo = null;
        });
      }
    }
  }

  Future<void> _removePhoto() async {
    HapticFeedback.selectionClick();

    // Get current transaction to find the receiptUrl
    model.BillTransaction? tx;
    final cached = BillTransactionsRepository.instance.cachedTransactions;
    if (cached != null) {
      try {
        tx = cached.firstWhere((t) => t.id == widget.transactionId);
      } catch (_) {}
    }

    final receiptUrl = tx?.receiptUrl;

    // Clear local state immediately for responsive UI
    setState(() {
      _photo = null;
      _photoSize = null;
    });

    // Delete from storage and update database
    if (receiptUrl != null && receiptUrl.isNotEmpty) {
      try {
        final client = Supabase.instance.client;

        // Delete from storage
        await client.storage.from('receipts').remove([receiptUrl]);

        // Update transaction to clear receiptUrl
        await BillTransactionsRepository.instance.updateBillTransaction(
          id: widget.transactionId,
          receiptUrl: '',
        );
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationOverlay(
      context,
      title: 'Delete this bill?',
      description: 'This action cannot be undone.',
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();

      setState(() {
        _isDeleting = true;
      });

      try {
        // Delete transaction from Supabase (cache will be updated automatically)
        await BillTransactionsRepository.instance.deleteBillTransaction(
          widget.transactionId,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted'),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back
          widget.onDelete?.call();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  List<Widget> _buildDetailsChildren(BuildContext context) {
    final widgets = <Widget>[];
    // Demo image at the top
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

    // Toggle control: button for Pending, placeholder for Paid
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
            rightLabel: _createdOn,
            rightLabelColor: Colors.black,
          ),
        ],
      ),
    );

    widgets.add(const SizedBox(height: 15));

    // Photos section: defaultPlace with no photo; grouped upper+lower when photo exists
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
              onTap: _isDeleting ? null : _toggleStatus,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _isDeleting ? null : () => _confirmDelete(context),
              behavior: HitTestBehavior.opaque,
              child: Opacity(
                opacity: _isDeleting ? 0.5 : 1.0,
                child: SettingsMenu(
                  label: 'Delete this bill',
                  place: SettingsMenuPlace.lower,
                  hideIcon: true,
                  labelColor: const Color(0xFFFF0000),
                  rightIcon: _isDeleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF0000),
                            ),
                          ),
                        )
                      : SvgPicture.asset(
                          AppIcons.arrow,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFF0000),
                            BlendMode.srcIn,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      widgets.add(
        GestureDetector(
          onTap: _isDeleting ? null : () => _confirmDelete(context),
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: _isDeleting ? 0.5 : 1.0,
            child: SettingsMenu(
              label: 'Delete this bill',
              hideIcon: true,
              labelColor: const Color(0xFFFF0000),
              rightIcon: _isDeleting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF0000),
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      AppIcons.arrow,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFF0000),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    widgets.add(const SizedBox(height: 50));

    return widgets;
  }

  void _toggleStatus() {
    if (_isSaving) return;

    // Toggle behavior: show success overlay only when going Pending/Overdue -> Paid
    if (_status != BillStatusType.paid) {
      HapticFeedback.mediumImpact();
      _updateTransactionOnServer(status: BillStatusType.paid).then((_) {
        if (!mounted) return;
        widget.onMarkAsPaid?.call();
        setState(() {
          _overlayVisible = true;
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _overlayVisible = false;
            });
          }
        });
      });
    } else {
      HapticFeedback.mediumImpact();
      final newStatus = _deadlineDate.isBefore(DateTime.now())
          ? BillStatusType.overdue
          : BillStatusType.pending;
      _updateTransactionOnServer(status: newStatus).then((_) {
        if (!mounted) return;
        widget.onMarkAsPaid?.call();
      });
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
                centerTitle: _categoryTitle,
                onBack: widget.onBack ?? () => Navigator.pop(context),
                hideAddButton: true,
                paddingTop: 68,
                paddingBottom: 10,
                paddingHorizontal: 15,
                hasText: false,
                width: MediaQuery.of(context).size.width,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
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
