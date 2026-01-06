import 'package:flutter/material.dart';
import 'package:brain2/widgets/text_top_bar.dart';
import 'package:brain2/widgets/settings_menu.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';
import 'package:brain2/overlays/photo_add_overlay.dart';
import 'package:brain2/overlays/text_edit.dart';
import 'package:brain2/overlays/created_overlay.dart';
import 'package:brain2/screens/bill_category.dart';
import 'package:brain2/screens/bills_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brain2/data/bill_categories_repository.dart';

class CreateNewBillCategoryPage extends StatefulWidget {
  const CreateNewBillCategoryPage({super.key});

  @override
  State<CreateNewBillCategoryPage> createState() =>
      _CreateNewBillCategoryPageState();
}

class _CreateNewBillCategoryPageState extends State<CreateNewBillCategoryPage> {
  String _categoryName = 'Set name';
  ImageProvider? _photo;
  bool _hasPromptedForName = false;
  bool _createdOverlayVisible = false;
  bool _isSaving = false;
  List<String> _existingCategoryNames = [];
  bool _isDuplicateName = false;

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();
    // Prompt for name on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasPromptedForName) {
        _hasPromptedForName = true;
        _editName(context);
      }
    });
  }

  Future<void> _loadExistingCategories() async {
    try {
      final categories = await BillCategoriesRepository.instance
          .fetchBillCategories();
      if (mounted) {
        setState(() {
          _existingCategoryNames = categories
              .map((cat) => cat.title.toLowerCase().trim())
              .toList();
        });
      }
    } catch (_) {
      // If error, continue with empty list
    }
  }

  bool _isNameUnique(String name) {
    final normalizedName = name.toLowerCase().trim();
    return !_existingCategoryNames.contains(normalizedName);
  }

  Future<void> _editName(BuildContext context) async {
    final updated = await showTextEditOverlay(
      context,
      title: 'Set name',
      initialValue: _categoryName == 'Set name' ? '' : _categoryName,
      hintText: 'Enter a name',
    );

    if (updated != null && updated.isNotEmpty && updated != _categoryName) {
      setState(() {
        _categoryName = updated;
        _isDuplicateName = !_isNameUnique(updated);
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

  Future<void> _handleCreateCategory() async {
    if (_createdOverlayVisible || _isSaving) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to add a category.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newCategory = await BillCategoriesRepository.instance
          .createBillCategory(
            title: _categoryName,
            imageUrl: null, // TODO: Add image upload support
          );

      if (!mounted) return;

      setState(() {
        _createdOverlayVisible = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Navigate to BillsPage first, then push the new category page on top
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BillsPage()),
        (route) => false,
      );

      // Small delay to ensure BillsPage is rendered
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillCategoryPage(
            categoryId: newCategory.id,
            categoryTitle: newCategory.title,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      final message = error is PostgrestException && error.message.isNotEmpty
          ? error.message
          : 'Failed to create category. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValidName =
        _categoryName.isNotEmpty &&
        _categoryName != 'Set name' &&
        _isNameUnique(_categoryName);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              TextTopBar(
                variant: isValidName
                    ? TextTopBarVariant.defaultActive
                    : TextTopBarVariant.doneInactive,
                title: 'Create new bill category',
                onBack: () => Navigator.pop(context),
                onAddPressed: isValidName ? _handleCreateCategory : () {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        // Demo circular image - tap to add/view photo
                        GestureDetector(
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
                                  : SvgPicture.asset(
                                      'assets/png_photos/bill_deafult_icon.svg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Name settings menu
                        SettingsMenu(
                          label: 'Name',
                          place: SettingsMenuPlace.defaultPlace,
                          icon: SvgPicture.asset(
                            AppIcons.home,
                            width: 24,
                            height: 24,
                          ),
                          rightText: true,
                          rightLabel: _categoryName,
                          onRightTap: () => _editName(context),
                        ),
                        if (_isDuplicateName)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 14,
                              right: 14,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.wavyWarning,
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFFFF3B30),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'A bill category with this name already exists.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFFF3B30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 15),
                        // Info message
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppIcons.info,
                                width: 25,
                                height: 25,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF6B6B6B),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'You can add individual transactions later under this bill.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF6B6B6B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
}
