import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:min_spendings/constants.dart';
import 'package:min_spendings/database/expense_database.dart';
import 'package:min_spendings/models/expense.dart';
import 'package:min_spendings/features/home/widgets/app_bar_widget.dart';
import 'package:min_spendings/components/home_page/expense_dialog.dart';
import 'package:min_spendings/components/home_page/expense_list_widget.dart';
import 'package:min_spendings/components/home_page/graph_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = expenseCategories[0];

  // future for graph and monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _currentMonthTotalFuture;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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
    _currentMonthTotalFuture =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  // handle bar tap
  void handleBarTap(int year, int month) {
    setState(() {
      selectedYear = year;
      selectedMonth = month;
    });

    // Update the future for the selected month total
    _currentMonthTotalFuture =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateMonthlyTotalForMonth(year, month);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        // display expenses for the selected month and year
        final List<Expense> selectedMonthExpenses = value.expenses
            .where((expense) =>
                expense.date.month == selectedMonth &&
                expense.date.year == selectedYear)
            .toList();

        // return UI
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          floatingActionButton: SizedBox(
            height: 60,
            child: FloatingActionButton.extended(
              onPressed: () {
                openExpenseBox(
                  context,
                  nameController,
                  amountController,
                  selectedCategory,
                  refreshData,
                  selectedMonth,
                  selectedYear,
                );
              },
              backgroundColor: Colors.blue.shade900,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add',
                      style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)), // Add text
                  const SizedBox(width: 10), // Space between text and icon
                  Icon(Icons.add, color: Colors.grey.shade300, size: 40),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          appBar: CustomAppBar(
            calculateCurrentMonthTotal: _currentMonthTotalFuture,
            currentMonthName: monthNames[selectedMonth - 1],
            currentYear: selectedYear,
          ),
          body: SafeArea(
            child: Column(
              children: [
                GraphWidget(
                  monthlyTotalsFuture: _monthlyTotalsFuture,
                  startYear: selectedYear,
                  onBarTap: handleBarTap,
                ),
                const SizedBox(height: 8),
                ExpenseListWidget(
                  currentMonthExpenses: selectedMonthExpenses,
                  nameController: nameController,
                  amountController: amountController,
                  selectedCategory: selectedCategory,
                  refreshData: refreshData,
                  selectedMonth: selectedMonth,
                  selectedYear: selectedYear,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
