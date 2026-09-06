import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatCurrency(num? amount) {
    if (amount == null) return 'Not Available';
    return _inrFormat.format(amount);
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'Not Available';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';
    return _dateTimeFormat.format(dateTime);
  }

  static String formatMultiple(num? count) {
    if (count == null) return 'Not Available';
    return '${count.toStringAsFixed(2)}x';
  }

  static String formatShares(num? shares) {
    if (shares == null) return 'Not Available';
    return NumberFormat.decimalPattern('en_IN').format(shares);
  }
}
