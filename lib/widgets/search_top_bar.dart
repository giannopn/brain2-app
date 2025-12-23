import 'package:flutter/material.dart';

import 'package:brain2/widgets/add_button.dart';
import 'package:brain2/widgets/search_bar.dart' as custom;

enum SearchTopBarVariant { home, searchMode, withBack }

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    super.key,
    this.variant = SearchTopBarVariant.home,
    this.onBack,
    this.onAdd,
    this.onClear,
    this.onSearchTap,
    this.width = 430,
  });

  final SearchTopBarVariant variant;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;
  final VoidCallback? onClear;
  final VoidCallback? onSearchTap;
  final double width;

  static const double _paddingH = 15;
  static const double _paddingTop = 68;
  static const double _paddingBottom = 10;
  static const double _gap = 10;
  static const Color _frameBackground = Colors.white;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case SearchTopBarVariant.searchMode:
        return _wrap(
          children: [
            _searchBar(state: custom.SearchBarState.typing),
            _addButton(),
          ],
        );
      case SearchTopBarVariant.withBack:
        return _wrap(children: [_backButton(), _searchBar(), _addButton()]);
      case SearchTopBarVariant.home:
        return _wrap(children: [_searchBar(), _addButton()]);
    }
  }

  Widget _wrap({required List<Widget> children}) {
    return Container(
      width: width,
      color: _frameBackground,
      padding: const EdgeInsets.fromLTRB(
        _paddingH,
        _paddingTop,
        _paddingH,
        _paddingBottom,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(width: _gap),
          ],
        ],
      ),
    );
  }

  Widget _searchBar({
    custom.SearchBarState state = custom.SearchBarState.defaultState,
  }) {
    return Expanded(
      child: custom.SearchBar(
        state: state,
        onClear: onClear,
        onTap: onSearchTap,
      ),
    );
  }

  Widget _addButton() {
    final bool isRotated = variant == SearchTopBarVariant.searchMode;
    return AnimatedRotation(
      turns: isRotated ? 0.625 : 0, // 225 degrees = 0.625 turns
      duration: const Duration(milliseconds: 200),
      child: AddButton(rotation: false, onPressed: onAdd),
    );
  }

  Widget _backButton() {
    return AddButton(rotation: true, onPressed: onBack);
  }
}
