import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toFormattedString([String pattern = 'dd MMM yyyy']) {
    return DateFormat(pattern).format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
