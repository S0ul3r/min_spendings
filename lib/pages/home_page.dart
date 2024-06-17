import 'package:flutter/material.dart';
import 'package:min_spendings/bar-graph/bar_graph.dart';
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

  // future for graph and monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read expenses db
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    // load futures
    refreshData();

    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotals();
    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
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
      builder: (context, value, child) {
        // get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        // calculate number of months since first month
        int monthsSinceStart = calculateMonthsSinceStart(startYear, startMonth, currentYear, currentMonth);

        // display expenses for the current month and current year
        List<Expense> currentMonthExpenses = 
          value.expenses.where(
            (expense) => expense.date.month == currentMonth && expense.date.year == currentYear
          ).toList();

        // return UI
        return Scaffold(
          backgroundColor: Colors.grey.shade400,
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                // loaded
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      '${snapshot.data!.toStringAsFixed(2)} zł',
                      style: const TextStyle(fontWeight: FontWeight.bold,),
                      ),
                      Text(
                      currentMonthName(),
                      style: const TextStyle(fontWeight: FontWeight.bold,),
                      ),
                    ],
                  );
                }
                // loading
                else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Grapg UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture, 
                    builder: (context, snapshot) {
                      // check if data loaded
                      if(snapshot.connectionState == ConnectionState.done) {
                        Map<String,double> monthlyTotals = snapshot.data ?? {};
                  
                        // create the list of monthly summary
                        List<double> monthlySummary = List.generate(
                          monthsSinceStart, 
                          (index) {
                            // get year and month
                            int year = startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            // get year-month string
                            String yearMonth = '$year-$month';

                            // return total for that month
                            return monthlyTotals[yearMonth] ?? 0.0;
                          }
                          );
                  
                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      }
                      else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );}
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Expenses list UI
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      // show latest expense first
                      index = currentMonthExpenses.length - 1 - index;
                      // get expense
                      Expense expense = currentMonthExpenses[index];
                      // return list tile
                      return CustomListTile(
                        title: expense.name, 
                        trailing: doubleToCurrency(expense.amount),
                        onEditPressed: (context) => openEditBox(expense),
                        onDeletePressed: (context) => openDeleteBox(expense),
                      );
                    }
                  ),
                )
              ],
            ),
          )
        );
      }
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
          // refresh graph data
          refreshData();
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
          // refresh graph data
          refreshData();
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

          // refresh graph data
          refreshData();
      },
      child: const Text('Delete'),
    );
  }
}