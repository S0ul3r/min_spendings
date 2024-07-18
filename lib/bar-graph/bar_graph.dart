import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:min_spendings/bar-graph/single_bar.dart';
import 'package:min_spendings/constants.dart';
import 'package:min_spendings/helper/helper_functions.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // List for data for each bar
  List<SingleBar> barData = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // we need to scroll to latest month automatically
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd());
  }

  // initialize bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => SingleBar(x: index, y: widget.monthlySummary[index]),
    );
  }

  // calculate max value for graph
  double calculateMaxValue() {
    double max = 500;
    for (var data in barData) {
      if (data.y > max) {
        max = data.y * 1.2;
      }
    }
    return max;
  }

  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: buildBarChart(),
      ),
    );
  }

  Widget buildBarChart() {
    return SizedBox(
      width: (barWidth + spaceBetweenBars) * barData.length,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: calculateMaxValue(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: buildTitlesData(),
          barGroups: buildBarGroups(),
          alignment: BarChartAlignment.center,
          groupsSpace: spaceBetweenBars,
        ),
      ),
    );
  }

  FlTitlesData buildTitlesData() {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: buildBottomTitles(),
    );
  }

  AxisTitles buildBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, titleMeta) {
          final monthIndex = (getCurrentMonthIndex() + value.toInt()) % 12;
          final text = monthNames[monthIndex];
          return SideTitleWidget(
            axisSide: titleMeta.axisSide,
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          );
        },
        reservedSize: 24,
      ),
    );
  }

  List<BarChartGroupData> buildBarGroups() {
    return barData.map((data) => BarChartGroupData(
      x: data.x,
      barRods: [
        BarChartRodData(
          toY: data.y,
          width: barWidth,
          borderRadius: BorderRadius.circular(6),
          color: Colors.lightBlue.shade900,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: calculateMaxValue(),
            color: Colors.grey.shade500,
          ),
        ),
      ],
    )).toList();
  }
}
