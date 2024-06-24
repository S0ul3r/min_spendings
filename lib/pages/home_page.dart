import 'package:flutter/material.dart';
import 'package:min_spendings/constants.dart';
import 'package:min_spendings/database/expense_database.dart';
import 'package:min_spendings/helper/helper_functions.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:provider/provider.dart';
import 'package:min_spendings/components/home_page/expense_dialog.dart';
import 'package:min_spendings/components/home_page/app_bar_widget.dart';
import 'package:min_spendings/components/home_page/graph_widget.dart';
import 'package:min_spendings/components/home_page/expense_list_widget.dart';

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
          floatingActionButton: SizedBox(
            height: 60,
            child: FloatingActionButton.extended(
              onPressed: () {
                openExpenseBox(context, nameController, amountController,
                    selectedCategory, refreshData);
              },
              backgroundColor: Colors.blue.shade900,
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
          appBar: CustomAppBar(
            calculateCurrentMonthTotal: _calculateCurrentMonthTotal,
            currentMonthName: currentMonthName(),
            currentYear: currentYear,
          ),
          body: SafeArea(
            child: Column(
              children: [
                GraphWidget(
                  monthlyTotalsFuture: _monthlyTotalsFuture,
                  monthsSinceStart: monthsSinceStart,
                  startMonth: startMonth,
                  startYear: startYear,
                ),
                const SizedBox(height: 5),
                ExpenseListWidget(
                  currentMonthExpenses: currentMonthExpenses,
                  nameController: nameController,
                  amountController: amountController,
                  selectedCategory: selectedCategory,
                  refreshData: refreshData,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
