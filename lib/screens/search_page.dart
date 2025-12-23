import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _hasText = _searchController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: SearchTopBarVariant.searchMode,
            searchController: _searchController,
            hasText: _hasText,
            onAdd: () => Navigator.of(context).pop(),
            onClear: () {
              _searchController.clear();
            },
            onSearchChanged: (value) {
              // Handle search logic here if needed
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
