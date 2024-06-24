import 'package:flutter/material.dart';
import 'package:min_spendings/bar_graph/bar_graph.dart';

class GraphWidget extends StatelessWidget {
  final Future<Map<String, double>>? monthlyTotalsFuture;
  final int monthsSinceStart;
  final int startMonth;
  final int startYear;

  const GraphWidget({
    super.key,
    required this.monthlyTotalsFuture,
    required this.monthsSinceStart,
    required this.startMonth,
    required this.startYear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: FutureBuilder<Map<String, double>>(
        future: monthlyTotalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final Map<String, double> monthlyTotals = snapshot.data ?? {};

            final List<double> monthlySummary = List.generate(
              monthsSinceStart,
              (index) {
                final int year = startYear + (startMonth + index - 1) ~/ 12;
                final int month = (startMonth + index - 1) % 12 + 1;
                final String yearMonth = '$year-$month';
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
    );
  }
}
