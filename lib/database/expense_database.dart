import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Expense> _expenses = [];

  // SETUP
  // initialize db
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // GETTERS
  List<Expense> get expenses => _expenses;

  // OPERATIONS
  // add expense
  Future<void> addExpense(Expense expense) async {
    await isar.writeTxn(() => isar.expenses.put(expense));

    // re-read from db
    await readExpenses();
  }

  // read expenses
  Future<void> readExpenses() async {
    // fetch expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give to local list
    _expenses.clear();
    _expenses.addAll(fetchedExpenses);

    // update UI
    notifyListeners();
  }

  // update expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;

    await isar.writeTxn(() => isar.expenses.put(updatedExpense));

    // re-read from db
    await readExpenses();
  }

  // delete expense
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));

    // re-read from db
    await readExpenses();
  }

  // HELPERS
  // get total amount
  Future<Map<String, double>> calculateMonthlyTotals() async {
    // read from db
    await readExpenses();

    // create a map to keep track of total expenses for each month and year
    Map<String, double> monthlyTotals = {};

    // loop through expenses
    for (var expense in _expenses) {
      // get month & year of expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      // check if yearMonth exists in map
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    // read from db
    await readExpenses();

    // get current month
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    // get total for current month and year
    double total = 0;
    for (var expense in _expenses) {
      if (expense.date.month == currentMonth &&
          expense.date.year == currentYear) {
        total += expense.amount;
      }
    }

    return total;
  }

  // get start month
  int getStartMonth() {
    if (_expenses.isEmpty) {
      return DateTime.now().month;
    }

    // sort expenses by date
    _expenses.sort((a, b) => a.date.compareTo(b.date));
    return _expenses.first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_expenses.isEmpty) {
      return DateTime.now().year;
    }

    // sort expenses by date
    _expenses.sort((a, b) => a.date.compareTo(b.date));
    return _expenses.first.date.year;
  }
}
