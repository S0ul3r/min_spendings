// convert string into double
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