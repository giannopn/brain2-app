import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/filters.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/widgets/home_page_cards.dart';
import 'package:brain2/widgets/bill_status.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasText = false;
  bool _showFiltersBorder = false;
  FilterActive _activeFilter = FilterActive.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _hasText = _searchController.text.isNotEmpty;
    });
  }

  void _onFilterChanged(FilterActive filter) {
    setState(() {
      _activeFilter = filter;
    });
    _searchFocusNode.unfocus();
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Column(
          children: [
            SearchTopBar(
              variant: SearchTopBarVariant.searchMode,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
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
            Container(
              decoration: BoxDecoration(
                border: _showFiltersBorder
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 4),
                child: Filters(
                  labelSecond: 'Bills',
                  labelThird: 'Subscriptions',
                  active: _activeFilter,
                  onChanged: _onFilterChanged,
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _dismissKeyboard();
                  }
                  final bool isScrolled = notification.metrics.pixels > 0;
                  if (isScrolled != _showFiltersBorder) {
                    setState(() => _showFiltersBorder = isScrolled);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: const [
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'ΚΟΙΝΟΧΡΗΣΤΑ',
                          status: BillStatusType.paid,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'ΔΕΗ',
                          status: BillStatusType.pending,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'ΕΥΔΑΠ',
                          status: BillStatusType.pending,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
                          status: BillStatusType.paid,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'ΔΕΗ - ΣΠΙΤΙ 2',
                          status: BillStatusType.overdue,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        BillsCard(
                          type: BillsCardType.general,
                          title: 'INTERNET',
                          status: BillStatusType.pending,
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        HomePageCard(
                          cardType: HomePageCardType.subscription,
                          title: 'Youtube Premium',
                          subtitle: 'Monthly, next on 10 Nov',
                          amount: '-9.99€',
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        HomePageCard(
                          cardType: HomePageCardType.subscription,
                          title: 'Netflix',
                          subtitle: 'Monthly, next on 10 Nov',
                          amount: '-9.99€',
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        HomePageCard(
                          cardType: HomePageCardType.subscription,
                          title: 'Spotify',
                          subtitle: 'Monthly, next on 10 Nov',
                          amount: '-9.99€',
                          width: double.infinity,
                        ),
                        SizedBox(height: 4),
                        HomePageCard(
                          cardType: HomePageCardType.subscription,
                          title: 'Google One',
                          subtitle: 'Monthly, next on 10 Nov',
                          amount: '-9.99€',
                          width: double.infinity,
                        ),
                        SizedBox(height: 61),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
