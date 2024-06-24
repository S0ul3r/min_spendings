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
    await _refreshExpenses();
  }

  // read expenses
  Future<void> readExpenses() async {
    await _refreshExpenses();
  }

  // update expense
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await _refreshExpenses();
  }

  // delete expense
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await _refreshExpenses();
  }

  // HELPERS
  Future<void> _refreshExpenses() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();
    _expenses.clear();
    _expenses.addAll(fetchedExpenses);
    notifyListeners();
  }

  // get total amount
  Future<Map<String, double>> calculateMonthlyTotals() async {
    await _refreshExpenses();

    // create a map to keep track of total expenses for each month and year
    Map<String, double> monthlyTotals = {};

    for (var expense in _expenses) {
      // get month & year of expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      // check if yearMonth exists in map
      monthlyTotals[yearMonth] = (monthlyTotals[yearMonth] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    await _refreshExpenses();
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    double total = _expenses
        .where((expense) => expense.date.month == currentMonth && expense.date.year == currentYear)
        .fold(0.0, (total, expense) => total + expense.amount);
    return total;
  }

  // calculate total for a specific month and year
  Future<double> calculateMonthlyTotalForMonth(int year, int month) async {
    await _refreshExpenses();
    double total = _expenses
        .where((expense) => expense.date.year == year && expense.date.month == month)
        .fold(0.0, (total, expense) => total + expense.amount);
    return total;
  }

  // get start month
  int getStartMonth() {
    if (_expenses.isEmpty) return DateTime.now().month;
    return _getSortedExpenses().first.date.month;
  }

  // get start year
  int getStartYear() {
    if (_expenses.isEmpty) return DateTime.now().year;
    return _getSortedExpenses().first.date.year;
  }

  List<Expense> _getSortedExpenses() {
    _expenses.sort((a, b) => a.date.compareTo(b.date));
    return _expenses;
  }
}