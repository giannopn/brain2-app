import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
    this.imageUrl,
    required this.name,
    required this.email,
    this.isDemoMode = false,
  });

  final String? imageUrl;
  final String name;
  final String email;
  final bool isDemoMode;

  // Typography
  static const double _fontSizeName = 22;
  static const double _fontSizeEmail = 16;

  // Colors
  static const Color _nameColor = Color(0xFF000000);
  static const Color _emailColor = Color(0xFF000000);
  static const Color _demoBgColor = Color(0xFF3B9FFF);

  // Sizing
  static const double _profileImageSize = 72;
  static const double _gapBetweenImageAndText = 14;
  static const double _gapBetweenNameAndEmail = 6;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Image
        _buildAvatar(),
        SizedBox(width: _gapBetweenImageAndText),
        // Profile Text Section
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: _fontSizeName,
                  fontWeight: FontWeight.w600,
                  color: _nameColor,
                  fontFamily: 'Inter',
                  height: 1,
                ),
              ),
              SizedBox(height: _gapBetweenNameAndEmail),
              // Email
              Text(
                email,
                style: const TextStyle(
                  fontSize: _fontSizeEmail,
                  fontWeight: FontWeight.w300,
                  color: _emailColor,
                  fontFamily: 'Inter',
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final letters = name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    if (letters.isEmpty) return '';
    if (letters.length == 1) return letters;
    return letters.substring(0, 2);
  }

  /// Builds avatar with graceful fallback to initials if no valid image URL.
  Widget _buildAvatar() {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) {
      return _initialsAvatar();
    }

    return Container(
      width: _profileImageSize,
      height: _profileImageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      // Fallback if image fails to load at runtime
      child: ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      ),
    );
  }

  Widget _initialsAvatar() {
    return Container(
      width: _profileImageSize,
      height: _profileImageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDemoMode ? _demoBgColor : _demoBgColor,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
