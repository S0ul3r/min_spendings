import 'package:flutter/material.dart';

const List<String> expenseCategories = [
  'Food',
  'Housing',
  'Transportation',
  'Debt',
  'Health',
  'Entertainment',
  'Subscription',
  'Clothing',
  'Misc',
  'Travel',
];

final List<String> monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

// Category icons
final Map<String, IconData> categoryIcons = {
  'Food': Icons.fastfood,
  'Housing': Icons.home,
  'Transportation': Icons.directions_car,
  'Debt': Icons.money_off,
  'Health': Icons.local_hospital,
  'Entertainment': Icons.movie,
  'Subscription': Icons.subscriptions,
  'Clothing': Icons.shopping_bag,
  'Misc': Icons.category,
  'Travel': Icons.airplanemode_active,
};