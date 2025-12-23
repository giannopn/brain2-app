import 'package:flutter/material.dart';

enum SearchBarState { defaultState, typing }

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    this.state = SearchBarState.defaultState,
    this.hintText = 'Search',
    this.onClear,
    this.onTap,
    this.width = 400,
  });

  final SearchBarState state;
  final String hintText;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final double width;

  static const double _height = 52;
  static const double _paddingH = 14;
  static const double _paddingV = 10;
  static const double _radius = 54;
  static const Color _background = Color(0xFFF1F1F1);
  static const Color _textColor = Color(0xFF000000);
  static const Color _clearBackground = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    final bool showClear = state == SearchBarState.typing;

    return SizedBox(
      width: width,
      height: _height,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _paddingH,
            vertical: _paddingV,
          ),
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 24, color: _textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: _textColor,
                  ),
                ),
              ),
              if (showClear) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: _clearBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.close, size: 16, color: _textColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
