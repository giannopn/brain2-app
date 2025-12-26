import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:brain2/widgets/button_large.dart';
import 'package:brain2/widgets/type_field.dart';

class PriceEditOverlay extends StatefulWidget {
  const PriceEditOverlay({
    super.key,
    required this.title,
    required this.initialValue,
    this.hintText,
    this.width = 400,
  });

  final String title;
  final String initialValue;
  final String? hintText;
  final double width;

  @override
  State<PriceEditOverlay> createState() => _PriceEditOverlayState();
}

class _PriceEditOverlayState extends State<PriceEditOverlay> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.fromLTRB(15, 15, 15, contentBottomPadding),
              children: [
                Text(
                  'Edit ${widget.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: TypeField(
                      label: widget.title,
                      controller: _controller,
                      hintText: widget.hintText,
                      focusNode: _focusNode,
                      showLabel: false,
                      textAlign: TextAlign.right,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 24,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'EUR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onSubmitted: (value) => _submit(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: widget.width,
                      child: ButtonLarge(
                        label: 'Save',
                        onPressed: _submit,
                        variant: ButtonLargeVariant.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: widget.width,
                      child: ButtonLarge(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    String value = _controller.text.trim();

    // Parse and format to 2 decimal places
    if (value.isNotEmpty) {
      try {
        final price = double.parse(value);
        value = price.toStringAsFixed(2);
      } catch (e) {
        // If parsing fails, keep the original value
      }
    }

    Navigator.of(context).pop(value);
  }
}

Future<String?> showPriceEditOverlay(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hintText,
  double width = 400,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return PriceEditOverlay(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        width: width,
      );
    },
  );
}
