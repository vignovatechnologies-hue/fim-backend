import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatCurrency(num amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return _currencyWithDecimals.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatRelativeTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final localDate = date.toLocal();
    final difference = now.difference(localDate);
    final timeStr = DateFormat('h:mm a').format(localDate);

    if (difference.inSeconds.abs() < 60) {
      return 'Just now ($timeStr)';
    } else if (now.year == localDate.year && now.month == localDate.month && now.day == localDate.day) {
      return 'Today, $timeStr';
    } else if (now.subtract(const Duration(days: 1)).day == localDate.day &&
        now.subtract(const Duration(days: 1)).month == localDate.month &&
        now.subtract(const Duration(days: 1)).year == localDate.year) {
      return 'Yesterday, $timeStr';
    } else if (difference.inDays < 7 && difference.inDays >= 0) {
      return '${DateFormat('E').format(localDate)}, $timeStr';
    } else {
      return DateFormat('dd MMM yyyy, h:mm a').format(localDate);
    }
  }
}
