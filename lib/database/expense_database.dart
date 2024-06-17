import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier{
  static late Isar isar;
  List<Expense> _expenses = [];

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
}