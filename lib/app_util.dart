import 'package:intl/intl.dart';
import 'package:khaanado/constants/app_constants.dart';

class AppUtil {
  AppUtil._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrPrecise = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _email = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static String rupees(num value) {
    if (value % 1 == 0) return _inr.format(value);
    return _inrPrecise.format(value);
  }

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidPassword(String value) =>
      value.length >= AppConstants.minPasswordLength;

  static bool isValidPhone(String value) =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim());

  static bool isValidPincode(String value) =>
      RegExp(r'^\d{6}$').hasMatch(value.trim());

  static int toasterDurationMs(String message) {
    final ms = message.length * AppConstants.toasterMsPerChar;
    return ms.clamp(AppConstants.toasterMinMs, AppConstants.toasterMaxMs);
  }
}
