import 'package:intl/intl.dart';

import '../constants/api_constants.dart';


class CurrencyUtils {
  CurrencyUtils._();

  static String format(double amount) => formatUsd(amount);

  static String formatUsd(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String formatKhr(double amountInUsd) {
    final khr = (amountInUsd * kUsdToKhrRate).round();
    final fmt = NumberFormat('#,###', 'en_US').format(khr);
    return '$fmt ៛';
  }

  static double usdToKhr(double usd) => usd * kUsdToKhrRate;
}
