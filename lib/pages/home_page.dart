import 'package:flutter/material.dart';
import 'package:min_spendings/components/custom_list_tile.dart';
import 'package:min_spendings/database/expense_database.dart';
import 'package:min_spendings/helper/helper_functions.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text contolllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    // read expenses
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // name and amount
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: 'Amount',
              ),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _addNewExpenseButton(),
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    // fill values from expense
    final String currentName = expense.name;
    String currentAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // name and amount
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: currentName,
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: currentAmount,
              ),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _editExpenseButton(expense),
        ],
      )
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // name and amount
            Text('Are you sure you want to delete ${expense.name}?'),
          ],
        ),
        actions: [
          _cancelButton(),
          _deleteExpenseButton(expense.id),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.expenses.length,
          itemBuilder: (context, index) {
            // get expense
            Expense expense = value.expenses[index];
            // return list tile
            return CustomListTile(
              title: expense.name, 
              trailing: doubleToCurrency(expense.amount),
              onEditPressed: (context) => openEditBox(expense),
              onDeletePressed: (context) => openDeleteBox(expense),
            );
          }
        )
      )
    );
  }

  // CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // close box
        Navigator.pop(context);
        // clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // SAVE BUTTON
  Widget _addNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        // only save when fields are filled
        if(nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          // close box
          Navigator.pop(context);
          // create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: stringToDouble(amountController.text),
            date: DateTime.now(),
            category: 'General'
          );
          // save to db
          await context.read<ExpenseDatabase>().addExpense(newExpense);
          // clear controllers
          nameController.clear();
          amountController.clear();
        } else {
          // show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all fields'),
              backgroundColor: Colors.red,
            )
          );
        }
      },
      child: const Text('Save'),
    );
  }

  // EDIT BUTTON
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // only save when fields has changed
        if(nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
          // close box
          Navigator.pop(context);
          // create new expense
          Expense updatedExpense = Expense(
            name: nameController.text.isEmpty ? expense.name : nameController.text,
            amount: amountController.text.isEmpty ? expense.amount : stringToDouble(amountController.text),
            date: DateTime.now(),
            category: 'General'
          );
          int expenseId = expense.id;
          // save to db
          await context.read<ExpenseDatabase>().updateExpense(expenseId, updatedExpense);
          // clear controllers
          nameController.clear();
          amountController.clear();
        } else {
          // show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have not changed anything'),
              backgroundColor: Colors.red,
            )
          );
        }
      },
      child: const Text('Save'),
    ); 
  }

  // DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // close box
        Navigator.pop(context);
        // delete expense
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: const Text('Delete'),
    );
  }
}