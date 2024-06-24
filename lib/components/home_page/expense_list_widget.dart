import 'package:flutter/material.dart';
import 'package:min_spendings/components/home_page/custom_list_tile.dart';
import 'package:min_spendings/components/home_page/expense_dialog.dart';
import 'package:min_spendings/helper/helper_functions.dart';
import 'package:min_spendings/models/expense.dart';

class ExpenseListWidget extends StatelessWidget {
  final List<Expense> currentMonthExpenses;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String selectedCategory;
  final Function refreshData;
  final int selectedMonth;
  final int selectedYear;

  const ExpenseListWidget({
    super.key,
    required this.currentMonthExpenses,
    required this.nameController,
    required this.amountController,
    required this.selectedCategory,
    required this.refreshData,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _buildExpenseList(),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      itemCount: currentMonthExpenses.length,
      itemBuilder: (context, index) {
        final int reversedIndex = currentMonthExpenses.length - 1 - index;
        final Expense expense = currentMonthExpenses[reversedIndex];
        return _buildExpenseTile(context, expense);
      },
    );
  }

  Widget _buildExpenseTile(BuildContext context, Expense expense) {
    return CustomListTile(
      title: expense.name,
      trailing: doubleToCurrency(expense.amount),
      category: expense.category,
      onEditPressed: (context) => openExpenseBox(
        context,
        nameController,
        amountController,
        selectedCategory,
        refreshData,
        selectedMonth,
        selectedYear,
        expense: expense,
      ),
      onDeletePressed: (context) => openDeleteBox(
        context,
        nameController,
        amountController,
        selectedCategory,
        refreshData,
        expense,
      ),
    );
  }
}