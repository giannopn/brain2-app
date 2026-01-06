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
import 'package:brain2/screens/add_new_bill.dart';
import 'package:brain2/overlays/text_edit.dart';
import 'package:brain2/overlays/delete_confirmation_overlay.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/data/bill_transactions_repository.dart';
import 'package:brain2/data/bill_categories_repository.dart';
import 'package:brain2/models/bill_transaction.dart' as model;

class BillCategoryPage extends StatefulWidget {
  const BillCategoryPage({
    super.key,
    required this.categoryId,
    this.categoryTitle = 'ΔΕΗ',
    this.onBack,
    this.onAdd,
  });

  final String categoryId;
  final String categoryTitle;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;

  @override
  State<BillCategoryPage> createState() => _BillCategoryPageState();
}

class _BillCategoryPageState extends State<BillCategoryPage> {
  late String _name;
  ImageProvider? _photo;
  List<model.BillTransaction> _recentTransactions = [];
  bool _isLoadingTransactions = true;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.categoryTitle;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await BillTransactionsRepository.instance
          .fetchTransactionsByCategory(categoryId: widget.categoryId);

      // Sort by due date descending (most recent first) and take first 4
      final sorted = List<model.BillTransaction>.from(transactions)
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

      if (mounted) {
        setState(() {
          _recentTransactions = sorted.take(4).toList();
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    }
  }

  String _formatDeadline(DateTime dueDate, model.BillStatus status) {
    final today = DateTime.now();
    final dateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysDiff = dateOnly.difference(todayOnly).inDays;

    if (daysDiff == 0) {
      return 'Today';
    }
    if (daysDiff == 1) {
      return 'Tomorrow';
    }
    if (daysDiff > 1) {
      return 'in $daysDiff days';
    }

    // Past dates
    if (daysDiff == -1 && status != model.BillStatus.paid) {
      return 'yesterday';
    }
    if (daysDiff < 0 && status != model.BillStatus.paid) {
      return '${-daysDiff} days ago';
    }

    // Paid and past deadline -> full date
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
    return '${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}';
  }

  BillStatusType _mapTransactionStatus(model.BillStatus status) {
    switch (status) {
      case model.BillStatus.paid:
        return BillStatusType.paid;
      case model.BillStatus.pending:
        return BillStatusType.pending;
      case model.BillStatus.overdue:
        return BillStatusType.overdue;
    }
  }

  Future<void> _editName(BuildContext context) async {
    final updated = await showTextEditOverlay(
      context,
      title: 'Edit name',
      initialValue: _name,
      hintText: 'Enter a name',
    );

    if (updated != null && updated.isNotEmpty && updated != _name) {
      // Check for duplicate name
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();
      final normalizedUpdated = updated.trim().toLowerCase();
      final isDuplicate = categories.any(
        (cat) =>
            cat.id != widget.categoryId &&
            cat.title.trim().toLowerCase() == normalizedUpdated,
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A category with this name already exists'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final updatedCategory = await BillCategoriesRepository.instance
            .updateBillCategory(id: widget.categoryId, title: updated);

        if (mounted) {
          setState(() {
            _name = updatedCategory.title;
            _isSaving = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update name: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

      setState(() {
        _isDeleting = true;
      });

      try {
        // Delete category from Supabase (CASCADE will delete transactions)
        await BillCategoriesRepository.instance.deleteBillCategory(
          widget.categoryId,
        );

        // Clear transactions cache to ensure consistency
        await BillTransactionsRepository.instance.fetchBillTransactions(
          forceRefresh: true,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill and history deleted'),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back with result indicating deletion occurred
          Navigator.pop(context, true);
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
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewBillPage(
                        categoryId: widget.categoryId,
                        categoryTitle: _name,
                      ),
                    ),
                  );

                  // Reload transactions from cache when returning
                  if (mounted) {
                    await _loadTransactions();
                  }
                },
            paddingTop: 68,
            paddingBottom: 10,
            paddingHorizontal: 15,
            hasText: false,
            width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                      rightLabel: _isSaving ? 'Saving...' : _name,
                      icon: SvgPicture.asset(
                        AppIcons.home,
                        width: 24,
                        height: 24,
                      ),
                      place: SettingsMenuPlace.defaultPlace,
                      onRightTap: _isSaving ? null : () => _editName(context),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bills Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CategoryTitle(
                      title: 'Transactions',
                      buttonLabel: 'View all',
                      onViewAll: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillTransactionsPage(
                              categoryId: widget.categoryId,
                              categoryTitle: _name,
                            ),
                          ),
                        );

                        // Reload transactions from cache when returning
                        if (mounted) {
                          await _loadTransactions();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Bill items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: _isLoadingTransactions
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _recentTransactions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: _recentTransactions.map((transaction) {
                              final formattedAmount =
                                  '${transaction.amount.toStringAsFixed(2)}€';
                              final formattedDeadline = _formatDeadline(
                                transaction.dueDate,
                                transaction.status,
                              );
                              final status = _mapTransactionStatus(
                                transaction.status,
                              );

                              return Column(
                                children: [
                                  BillsCard(
                                    type: BillsCardType.detailed,
                                    title: _name,
                                    subtitle: formattedDeadline,
                                    amount: formattedAmount,
                                    status: status,
                                    width: double.infinity,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BillDetailsPage(
                                            transactionId: transaction.id,
                                          ),
                                        ),
                                      );

                                      // Reload transactions from cache when returning
                                      if (mounted) {
                                        await _loadTransactions();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 30),
                  // Delete button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: _isDeleting ? null : () => _confirmDelete(context),
                      behavior: HitTestBehavior.opaque,
                      child: Opacity(
                        opacity: _isDeleting ? 0.5 : 1.0,
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
                                  _isDeleting ? 'Deleting...' : 'Delete $_name',
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
                              _isDeleting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                            ],
                          ),
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
