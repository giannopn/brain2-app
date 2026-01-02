import 'package:flutter/material.dart';

import 'package:brain2/widgets/button_large.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';

class PhotoAddOverlay extends StatelessWidget {
  const PhotoAddOverlay({super.key, required this.title, this.width = 400});

  final String title;
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
              Text(
                'Add photo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: width,
                    child: ButtonLarge(
                      label: 'Take a photo',
                      onPressed: () => Navigator.of(context).pop('camera'),
                      variant: ButtonLargeVariant.primary,
                      leading: SvgPicture.asset(
                        AppIcons.camera,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFFFFFF),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width,
                    child: ButtonLarge(
                      label: 'Upload from gallery',
                      onPressed: () => Navigator.of(context).pop('gallery'),
                      variant: ButtonLargeVariant.primary,
                      leading: SvgPicture.asset(
                        AppIcons.folder,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFFFFFF),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: width,
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
    );
  }
}

Future<String?> showPhotoAddOverlay(
  BuildContext context, {
  String title = 'Add photo',
  double width = 400,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return PhotoAddOverlay(title: title, width: width);
    },
  );
}
