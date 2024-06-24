import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:min_spendings/bar_graph/single_bar.dart';
import 'package:min_spendings/constants.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;
  final Function(int) onBarTap;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
    required this.onBarTap,
  });

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

    // Calculate bar width and space between bars based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = screenWidth / 20;
    final double spaceBetweenBars = screenWidth / 40;

    return _buildScrollableBarChart(barWidth, spaceBetweenBars);
  }

  Widget _buildScrollableBarChart(double barWidth, double spaceBetweenBars) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: _buildBarChart(barWidth, spaceBetweenBars),
      ),
    );
  }

  Widget _buildBarChart(double barWidth, double spaceBetweenBars) {
    return SizedBox(
      width: (barWidth + spaceBetweenBars) * barData.length,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: calculateMaxValue(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: _buildTitlesData(),
          barGroups: _buildBarGroups(barWidth),
          alignment: BarChartAlignment.center,
          groupsSpace: spaceBetweenBars,
          barTouchData: _buildBarTouchData(),
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (group) => Colors.grey.shade800,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            rod.toY.toString(),
            const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          );
        },
      ),
      touchCallback: (FlTouchEvent event, barTouchResponse) {
        if (barTouchResponse != null &&
            barTouchResponse.spot != null &&
            event is FlTapUpEvent) {
          widget.onBarTap(barTouchResponse.spot!.touchedBarGroupIndex);
        }
      },
      handleBuiltInTouches: true,
      touchExtraThreshold: EdgeInsets.symmetric(vertical: calculateMaxValue()),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: _buildBottomTitles(),
    );
  }

  AxisTitles _buildBottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, titleMeta) {
          final monthIndex = (widget.startMonth + value.toInt() - 1) % 12;
          final text = monthNames[monthIndex];
          return SideTitleWidget(
            axisSide: titleMeta.axisSide,
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          );
        },
        reservedSize: 24,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double barWidth) {
    return barData
        .map((data) => BarChartGroupData(
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
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ))
        .toList();
  }
}