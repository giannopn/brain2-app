import 'package:flutter/material.dart';
import 'package:brain2/widgets/search_top_bar.dart';
import 'package:brain2/widgets/bill_status.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/screens/bill_details_page.dart';

class BillTransactionsPage extends StatelessWidget {
  const BillTransactionsPage({
    super.key,
    this.categoryTitle = 'ΔΕΗ',
    this.totalAmount = '-1128€',
    this.onBack,
    this.onAdd,
  });

  final String categoryTitle;
  final String totalAmount;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final List<TransactionItem> transactions = [
      TransactionItem(
        title: categoryTitle,
        subtitle: 'in 6 days',
        amount: '-46.28€',
        status: BillStatusType.pending,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '17 November 2025',
        amount: '-34.76€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '6 October 2025',
        amount: '-37.58€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '4 September 2025',
        amount: '-32.14€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '4 August 2025',
        amount: '-65.31€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '6 July 2025',
        amount: '-56.98€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '6 June 2025',
        amount: '-47.55€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '2 May 2025',
        amount: '-56.77€',
        status: BillStatusType.paid,
      ),
      TransactionItem(
        title: categoryTitle,
        subtitle: '4 April 2025',
        amount: '-52.10€',
        status: BillStatusType.paid,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SearchTopBar(
            variant: SearchTopBarVariant.withBack,
            centerTitle: categoryTitle,
            onBack: onBack ?? () => Navigator.pop(context),
            hideAddButton: true,
            paddingTop: 68,
            paddingBottom: 10,
            paddingHorizontal: 15,
            hasText: false,
            width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction History header with total
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          totalAmount,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transaction items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        for (int i = 0; i < transactions.length; i++) ...[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BillDetailsPage(
                                    categoryTitle: transactions[i].title,
                                    amount: transactions[i].amount,
                                    status: transactions[i].status,
                                    deadline: _toAbbrevDate(
                                      transactions[i].subtitle,
                                    ),
                                    createdOn: '1 Nov 2025',
                                  ),
                                ),
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: BillsCard(
                              type: BillsCardType.detailed,
                              title: transactions[i].title,
                              subtitle: transactions[i].subtitle,
                              amount: transactions[i].amount,
                              status: transactions[i].status,
                              width: double.infinity,
                            ),
                          ),
                          if (i < transactions.length - 1)
                            const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _DeadlineFormat on BillTransactionsPage {
  /// Converts strings like "17 November 2025" to "17 Nov 2025".
  /// If the input is relative (e.g., "in 6 days"), returns a default
  /// example date in the desired style.
  String _toAbbrevDate(String input) {
    const monthMap = {
      'January': 'Jan',
      'February': 'Feb',
      'March': 'Mar',
      'April': 'Apr',
      'May': 'May',
      'June': 'Jun',
      'July': 'Jul',
      'August': 'Aug',
      'September': 'Sep',
      'October': 'Oct',
      'November': 'Nov',
      'December': 'Dec',
    };

    final regex = RegExp(
      r'^(\d{1,2})\s+(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{4})$',
    );
    final match = regex.firstMatch(input);
    if (match != null) {
      final day = match.group(1)!;
      final monthFull = match.group(2)!;
      final year = match.group(3)!;
      final abbr = monthMap[monthFull] ?? monthFull;
      return '$day $abbr $year';
    }

    if (input.toLowerCase().startsWith('in ')) {
      // Fallback to an example date in the correct style.
      return '20 Nov 2025';
    }

    // If already in desired style or an unexpected format, return as-is.
    return input;
  }
}

class TransactionItem {
  final String title;
  final String subtitle;
  final String amount;
  final BillStatusType status;

  TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
  });
}
