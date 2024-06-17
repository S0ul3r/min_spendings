import 'package:isar/isar.dart';

// generate isar file, command: dart run build_runner build
part 'expense.g.dart';

@Collection()
class Expense{
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.name, 
    required this.amount, 
    required this.date, 
    required this.category
  });
}