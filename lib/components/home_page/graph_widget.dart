import 'package:flutter/material.dart';
import 'package:min_spendings/bar_graph/bar_graph.dart';

class GraphWidget extends StatelessWidget {
  final Future<Map<String, double>>? monthlyTotalsFuture;
  final int startYear;
  final Function(int, int) onBarTap;

  const GraphWidget({
    super.key,
    required this.monthlyTotalsFuture,
    required this.startYear,
    required this.onBarTap,
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
              12,
              (index) {
                final int month = index + 1;
                final String yearMonth = '$startYear-$month';
                return monthlyTotals[yearMonth] ?? 0.0;
              },
            );

            return MyBarGraph(
              monthlySummary: monthlySummary,
              startMonth: 1,
              onBarTap: (index) {
                final int month = index + 1;
                onBarTap(startYear, month);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
