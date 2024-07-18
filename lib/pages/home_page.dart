import 'package:flutter/material.dart';
import 'package:min_spendings/bar-graph/bar_graph.dart';
import 'package:min_spendings/components/custom_list_tile.dart';
import 'package:min_spendings/constants.dart';
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
  // text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String selectedCategory = expenseCategories[0];

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
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  // open expense box
  void openExpenseBox({Expense? expense}) {
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
              const SizedBox(height: 8), // Added space between the text fields
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
              const SizedBox(
                  height: 8), // Added space between the text field and dropdown
              Container(
                width: double
                    .infinity, // Makes the dropdown take the full width available
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: DropdownButton<String>(
                  isExpanded: true, // Expands the dropdown to fill the container
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
                  underline: Container(), // Removes underline
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey.shade800,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 40), // Customized dropdown arrow
                ),
              ),
            ],
          ),
          actions: [
            _cancelButton(),
            _saveExpenseButton(expense),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        // get dates
        final int startMonth = value.getStartMonth();
        final int startYear = value.getStartYear();
        final int currentMonth = DateTime.now().month;
        final int currentYear = DateTime.now().year;

        // calculate number of months since first month
        final int monthsSinceStart = calculateMonthsSinceStart(
            startYear, startMonth, currentYear, currentMonth);

        // display expenses for the current month and current year
        final List<Expense> currentMonthExpenses = value.expenses
            .where((expense) =>
                expense.date.month == currentMonth &&
                expense.date.year == currentYear)
            .toList();

        // return UI
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          floatingActionButton: Container(
            height: 60, // Set the desired height here
            child: FloatingActionButton.extended(
              onPressed: () {
                openExpenseBox();
              },
              backgroundColor:
                  Colors.blue.shade900, // Change button color to blue shade900
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add',
                      style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)), // Add text "Add"
                  const SizedBox(width: 10), // Add space between text and icon
                  Icon(Icons.add, color: Colors.grey.shade300, size: 40),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentMonthName()} $currentYear',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${snapshot.data!.toStringAsFixed(2)} zł',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Graph UI
                SizedBox(
                  height: 250,
                  child: FutureBuilder<Map<String, double>>(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      // check if data loaded
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        final Map<String, double> monthlyTotals =
                            snapshot.data ?? {};

                        // create the list of monthly summary
                        final List<double> monthlySummary = List.generate(
                          monthsSinceStart,
                          (index) {
                            // get year and month
                            final int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            final int month = (startMonth + index - 1) % 12 + 1;

                            // get year-month string
                            final String yearMonth = '$year-$month';

                            // return total for that month
                            return monthlyTotals[yearMonth] ?? 0.0;
                          },
                        );

                        return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth,
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),

                const SizedBox(height: 5),

                // Expenses list UI
                Expanded(
                  child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      final int reversedIndex =
                          currentMonthExpenses.length - 1 - index;
                      final Expense expense =
                          currentMonthExpenses[reversedIndex];
                      return buildExpenseListTile(expense);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // SAVE BUTTON
  Widget _saveExpenseButton(Expense? expense) {
    return MaterialButton(
      onPressed: () async {
        // only save when fields are filled
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty &&
            selectedCategory.isNotEmpty) {
          // close box
          Navigator.pop(context);
          if (expense == null) {
            // create new expense
            Expense newExpense = Expense(
              name: nameController.text,
              amount: stringToDouble(amountController.text),
              date: DateTime.now(),
              category: selectedCategory,
            );
            // save to db
            await context.read<ExpenseDatabase>().addExpense(newExpense);
          } else {
            // create new expense
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
            // save to db
            await context
                .read<ExpenseDatabase>()
                .updateExpense(expenseId, updatedExpense);
          }
          // refresh graph data
          refreshData();
          // clear controllers
          nameController.clear();
          amountController.clear();
          selectedCategory = expenseCategories[0];
        } else {
          // show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all fields'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Save',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
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
                  _cancelButton(),
                  _deleteExpenseButton(expense.id),
                ],
              ),
            ));
  }

  // DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // close box
        Navigator.pop(context);
        // delete from db
        await context.read<ExpenseDatabase>().deleteExpense(id);
        // refresh graph data
        refreshData();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Delete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
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
        selectedCategory = expenseCategories[0];
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: const Text('Cancel',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Extract the logic for building the expense list tile into a separate method
  Widget buildExpenseListTile(Expense expense) {
    return CustomListTile(
      title: expense.name,
      trailing: doubleToCurrency(expense.amount),
      category: expense.category,
      onEditPressed: (context) => openExpenseBox(expense: expense),
      onDeletePressed: (context) => openDeleteBox(expense),
    );
  }
}
