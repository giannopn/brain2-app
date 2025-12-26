import 'package:flutter/material.dart';

import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/filters.dart';
import 'package:brain2/models/search_item.dart';
import 'package:brain2/data/mock_search_data.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  FilterActive _activeFilter = FilterActive.all;
  List<SearchItem> _filteredBills = [];
  bool _showFiltersBorder = false;

  @override
  void initState() {
    super.initState();
    _filterBills();
  }

  void _filterBills() {
    // Get only bills from mock data
    List<SearchItem> bills = mockSearchItems
        .where((item) => item.type == SearchItemType.bill)
        .toList();

    // Filter by status based on active filter
    if (_activeFilter == FilterActive.second) {
      // Only pending bills
      bills = bills
          .where(
            (item) =>
                (item.card as dynamic).status.toString() ==
                'BillStatusType.pending',
          )
          .toList();
    } else if (_activeFilter == FilterActive.third) {
      // Only overdue bills
      bills = bills
          .where(
            (item) =>
                (item.card as dynamic).status.toString() ==
                'BillStatusType.overdue',
          )
          .toList();
    }
    // If _activeFilter == FilterActive.all, show all bills

    setState(() {
      _filteredBills = bills;
    });
  }

  void _onFilterChanged(FilterActive filter) {
    setState(() {
      _activeFilter = filter;
    });
    _filterBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            onBack: () => Navigator.of(context).pop(),
            onAdd: () {
              // Handle add bill action
            },
            onSearchTap: () {
              // Handle search tap
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
                labelAll: 'All',
                labelSecond: 'Pending',
                labelThird: 'Overdue',
                active: _activeFilter,
                onChanged: _onFilterChanged,
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final bool isScrolled = notification.metrics.pixels > 0;
                if (isScrolled != _showFiltersBorder) {
                  setState(() => _showFiltersBorder = isScrolled);
                }
                return false;
              },
              child: _filteredBills.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No bills found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _filteredBills.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const SizedBox(height: 4);
                        }
                        if (index == _filteredBills.length + 1) {
                          return const SizedBox(height: 61);
                        }
                        final item = _filteredBills[index - 1];
                        return Column(
                          children: [item.card, const SizedBox(height: 4)],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
