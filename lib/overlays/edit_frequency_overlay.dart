import 'package:flutter/material.dart';

import 'package:brain2/widgets/button_large.dart';
import 'package:brain2/widgets/select_menu.dart';

class EditFrequencyOverlay extends StatelessWidget {
  const EditFrequencyOverlay({
    super.key,
    this.items = const ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'],
    required this.selectedIndex,
    this.onSelected,
    this.onSave,
    this.onCancel,
    this.width = 400,
  }) : assert(selectedIndex >= 0);

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final double width;

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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.only(top: 10),
        child: SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.fromLTRB(15, 15, 15, contentBottomPadding),
            children: [
              const Text(
                'Edit frequency',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SelectMenu(
                  items: items,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                  width: width,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: width,
                    child: ButtonLarge(
                      label: 'Save',
                      onPressed: onSave,
                      variant: ButtonLargeVariant.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width,
                    child: ButtonLarge(label: 'Cancel', onPressed: onCancel),
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
