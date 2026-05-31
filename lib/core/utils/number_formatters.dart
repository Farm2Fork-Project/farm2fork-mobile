import 'dart:ui';

import 'package:intl/intl.dart';

String formatCurrencyAmount(num amount, Locale locale) {
  final hasDecimals = amount % 1 != 0;
  return NumberFormat.decimalPatternDigits(
    locale: locale.toLanguageTag(),
    decimalDigits: hasDecimals ? 2 : 0,
  ).format(amount);
}

String formatCompactNumber(num amount, Locale locale) {
  final hasDecimals = amount % 1 != 0;
  return NumberFormat.decimalPatternDigits(
    locale: locale.toLanguageTag(),
    decimalDigits: hasDecimals ? 1 : 0,
  ).format(amount);
}
