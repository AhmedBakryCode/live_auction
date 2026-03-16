import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static String format(double amount) {
    return NumberFormat.currency(
      locale: 'ar_EG',
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  static String formatCompact(double amount) {
    return NumberFormat.compactCurrency(
      locale: 'ar_EG',
      symbol: AppConstants.currencySymbol,
      decimalDigits: 0,
    ).format(amount);
  }
}
