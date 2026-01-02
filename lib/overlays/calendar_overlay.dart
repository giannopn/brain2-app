import 'package:flutter/material.dart';

import 'package:brain2/widgets/button_large.dart';

class CalendarOverlay extends StatefulWidget {
  const CalendarOverlay({
    super.key,
    required this.title,
    required this.initialDate,
  });

  final String title;
  final DateTime initialDate;

  @override
  State<CalendarOverlay> createState() => _CalendarOverlayState();
}

class _CalendarOverlayState extends State<CalendarOverlay> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.fromLTRB(15, 15, 15, contentBottomPadding),
              children: [
                Text(
                  'Select ${widget.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 400,
                      child: ButtonLarge(
                        label: 'Save',
                        onPressed: _submit,
                        variant: ButtonLargeVariant.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400,
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
    Navigator.of(context).pop(_selectedDate);
  }
}

Future<DateTime?> showCalendarOverlay(
  BuildContext context, {
  required String title,
  required DateTime initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CalendarOverlay(title: title, initialDate: initialDate);
    },
  );
}
