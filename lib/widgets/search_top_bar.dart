import 'package:flutter/material.dart';

import 'package:brain2/widgets/add_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brain2/theme/app_icons.dart';
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
    this.onSearchChanged,
    this.searchController,
    this.searchFocusNode,
    this.hasText = false,
    this.width = 430,
    this.paddingHorizontal = _paddingH,
    this.paddingTop = _paddingTop,
    this.paddingBottom = _paddingBottom,
  });

  final SearchTopBarVariant variant;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;
  final VoidCallback? onClear;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final bool hasText;
  final double width;
  final double paddingHorizontal;
  final double paddingTop;
  final double paddingBottom;

  static const double _paddingH = 15;
  static const double _paddingTop = 68;
  static const double _paddingBottom = 10;
  static const double _gap = 10;
  static const Color _frameBackground = Color.fromARGB(255, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case SearchTopBarVariant.searchMode:
        return _wrap(
          children: [
            _searchBar(
              state: hasText
                  ? custom.SearchBarState.typing
                  : custom.SearchBarState.defaultState,
            ),
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
      padding: EdgeInsets.fromLTRB(
        paddingHorizontal,
        paddingTop,
        paddingHorizontal,
        paddingBottom,
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
        onChanged: onSearchChanged,
        controller: searchController,
        focusNode: searchFocusNode,
        enableInput: variant == SearchTopBarVariant.searchMode,
      ),
    );
  }

  Widget _addButton() {
    return AddButton(
      rotation: variant == SearchTopBarVariant.searchMode,
      onPressed: onAdd,
    );
  }

  Widget _backButton() {
    // Use the arrow icon for back, matching the Figma design
    return AddButton(
      onPressed: onBack,
      icon: SvgPicture.asset(AppIcons.backArrowBig),
    );
  }
}
