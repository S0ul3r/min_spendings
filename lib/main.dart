import 'package:flutter/material.dart';
import 'package:min_spendings/database/expense_database.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var logger = Logger();

  // Initialize the database
  try {
    await ExpenseDatabase.init();
  } catch (e) {
    logger.e('Failed to initialize the database');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}