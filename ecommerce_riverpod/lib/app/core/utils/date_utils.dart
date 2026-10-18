import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date, {String format = 'dd MMM yyyy'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime? date, {String format = 'dd MMM yyyy, hh:mm a'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  static String timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }
}
