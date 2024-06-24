import 'package:flutter/material.dart';
import 'package:min_spendings/components/home_page/button_widgets.dart';
import 'package:min_spendings/constants.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:min_spendings/helper/helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:min_spendings/database/expense_database.dart';

void openExpenseBox(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController amountController,
    String selectedCategory,
    Function refreshData,
    {Expense? expense}) {
  if (expense != null) {
    nameController.text = expense.name;
    amountController.text = expense.amount.toString();
    selectedCategory = expense.category;
  } else {
    nameController.clear();
    amountController.clear();
    selectedCategory = expenseCategories[0];
  }

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade600),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCategory,
                items: expenseCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                underline: Container(),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey.shade700,
                icon: const Icon(Icons.arrow_drop_down,
                    color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
        actions: [
          CancelButton(onPressed: () {
            Navigator.pop(context);
            nameController.clear();
            amountController.clear();
            selectedCategory = expenseCategories[0];
          }),
          SaveButton(
              onPressed: (expense) async {
                if (nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    selectedCategory.isNotEmpty) {
                  Navigator.pop(context);
                  if (expense == null) {
                    Expense newExpense = Expense(
                      name: nameController.text,
                      amount: stringToDouble(amountController.text),
                      date: DateTime.now(),
                      category: selectedCategory,
                    );
                    await context
                        .read<ExpenseDatabase>()
                        .addExpense(newExpense);
                  } else {
                    Expense updatedExpense = Expense(
                      name: nameController.text.isEmpty
                          ? expense.name
                          : nameController.text,
                      amount: amountController.text.isEmpty
                          ? expense.amount
                          : stringToDouble(amountController.text),
                      date: expense.date,
                      category: selectedCategory,
                    );
                    int expenseId = expense.id;
                    await context
                        .read<ExpenseDatabase>()
                        .updateExpense(expenseId, updatedExpense);
                  }
                  refreshData();
                  nameController.clear();
                  amountController.clear();
                  selectedCategory = expenseCategories[0];
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              expense: expense),
        ],
      ),
    ),
  );
}

void openDeleteBox(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController amountController,
    String selectedCategory,
    Function refreshData,
    Expense expense) {
  showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: Colors.grey.shade800,
              title: const Text('Delete Expense',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to delete ${expense.name}?',
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
              actions: [
                CancelButton(onPressed: () {
                  Navigator.pop(context);
                  nameController.clear();
                  amountController.clear();
                  selectedCategory = expenseCategories[0];
                }),
                DeleteButton(
                    onPressed: (id) async {
                      Navigator.pop(context);
                      await context.read<ExpenseDatabase>().deleteExpense(id);
                      refreshData();
                    },
                    id: expense.id),
              ],
            ),
          ));
}
