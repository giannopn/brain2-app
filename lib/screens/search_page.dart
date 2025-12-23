import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchTopBarVariant _variant = SearchTopBarVariant.home;

  @override
  void initState() {
    super.initState();
    // Trigger animation after page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _variant = SearchTopBarVariant.searchMode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: _variant,
            onAdd: () => Navigator.of(context).pop(),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
