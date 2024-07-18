// convert string into double
import 'dart:ui';
import 'package:intl/intl.dart';

double stringToDouble(String value) {
  // return value or 0 if value is empty
  double? result = double.tryParse(value);
  return result ?? 0;
}

// format double into currency
String doubleToCurrency(double value) {
  final result = NumberFormat.currency(
    locale: 'pl_PL',
    symbol: 'zł',
    decimalDigits: 2,
  ).format(value);
  return result;
}

// calculate number of months since start
int calculateMonthsSinceStart(int startYear, startMonth, currentYear, currentMonth) {
  return (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
}

// current month name
String currentMonthName() {
  return DateFormat.MMMM().format(DateTime.now());
}

int getCurrentMonthIndex() {
  return DateTime.now().month - 1;
}

Color getColorFromCategory(String category) {
  final int hash = category.hashCode;
  final int r = (hash & 0xFF0000) >> 16;
  final int g = (hash & 0x00FF00) >> 8;
  final int b = hash & 0x0000FF;
  return Color.fromRGBO(r, g, b, 1.0);
}
