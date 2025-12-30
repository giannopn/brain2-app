import 'package:flutter/material.dart';

import 'package:brain2/widgets/button_large.dart';
import 'package:brain2/widgets/swipe_bar.dart';

class DeleteConfirmationSwipeOverlay extends StatefulWidget {
  const DeleteConfirmationSwipeOverlay({
    super.key,
    required this.title,
    this.description = 'Are you sure you want to delete this?',
    this.confirmText = 'Swipe to confirm',
    this.width = 400,
  });

  final String title;
  final String description;
  final String confirmText;
  final double width;

  @override
  State<DeleteConfirmationSwipeOverlay> createState() =>
      _DeleteConfirmationSwipeOverlayState();
}

class _DeleteConfirmationSwipeOverlayState
    extends State<DeleteConfirmationSwipeOverlay> {
  void _onSwipeEnd(double progress) {
    if (progress >= 0.95) {
      // Swiped to the end (95% or more)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double contentBottomPadding = (50 - safeAreaBottom).clamp(0.0, 50.0);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 10),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.fromLTRB(15, 15, 15, contentBottomPadding),
            children: [
              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 6),
              // Confirm text
              Text(
                widget.confirmText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              // SwipeBar and Cancel button container
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: widget.width,
                    child: SwipeBar(
                      initialProgress: 0.0,
                      onDragEnd: _onSwipeEnd,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: widget.width,
                    child: ButtonLarge(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showDeleteConfirmationSwipeOverlay(
  BuildContext context, {
  String title = 'Delete Account?',
  String description =
      'Deleting your account is permanent. You will immediately lose access to all your data. Are you sure?',
  String confirmText = 'Swipe to confirm',
  double width = 400,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DeleteConfirmationSwipeOverlay(
        title: title,
        description: description,
        confirmText: confirmText,
        width: width,
      );
    },
  );
}
