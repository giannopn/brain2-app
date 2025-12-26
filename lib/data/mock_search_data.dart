import 'package:brain2/models/search_item.dart';
import 'package:brain2/widgets/bills_cards.dart';
import 'package:brain2/widgets/home_page_cards.dart';
import 'package:brain2/widgets/bill_status.dart';

/// Mock data for the search page.
/// Contains a mix of bills and subscriptions.
final List<SearchItem> mockSearchItems = [
  // Bills
  const SearchItem(
    title: 'ΚΟΙΝΟΧΡΗΣΤΑ',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'ΚΟΙΝΟΧΡΗΣΤΑ',
      status: BillStatusType.paid,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'ΔΕΗ',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'ΔΕΗ',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'ΕΥΔΑΠ',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'ΕΥΔΑΠ',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'ΦΥΣΙΚΟ ΑΕΡΙΟ',
      status: BillStatusType.paid,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'ΔΕΗ - ΣΠΙΤΙ 2',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'ΔΕΗ - ΣΠΙΤΙ 2',
      status: BillStatusType.overdue,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'INTERNET',
    type: SearchItemType.bill,
    card: BillsCard(
      type: BillsCardType.general,
      title: 'INTERNET',
      status: BillStatusType.pending,
      width: double.infinity,
    ),
  ),
  // Subscriptions
  const SearchItem(
    title: 'Youtube Premium',
    type: SearchItemType.subscription,
    card: HomePageCard(
      cardType: HomePageCardType.subscription,
      title: 'Youtube Premium',
      subtitle: 'Monthly, next on 10 Nov',
      amount: '-9.99€',
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'Netflix',
    type: SearchItemType.subscription,
    card: HomePageCard(
      cardType: HomePageCardType.subscription,
      title: 'Netflix',
      subtitle: 'Monthly, next on 10 Nov',
      amount: '-9.99€',
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'Spotify',
    type: SearchItemType.subscription,
    card: HomePageCard(
      cardType: HomePageCardType.subscription,
      title: 'Spotify',
      subtitle: 'Monthly, next on 10 Nov',
      amount: '-9.99€',
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'Google One',
    type: SearchItemType.subscription,
    card: HomePageCard(
      cardType: HomePageCardType.subscription,
      title: 'Google One',
      subtitle: 'Monthly, next on 10 Nov',
      amount: '-9.99€',
      width: double.infinity,
    ),
  ),
  const SearchItem(
    title: 'Google Two',
    type: SearchItemType.subscription,
    card: HomePageCard(
      cardType: HomePageCardType.subscription,
      title: 'Google Two',
      subtitle: 'Monthly, next on 10 Nov',
      amount: '-9.99€',
      width: double.infinity,
    ),
  ),
];
