import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:min_spendings/bar-graph/single_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({ 
    super.key, 
    required this.monthlySummary, 
    required this.startMonth 
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // List for data for each bar
  List<SingleBar> barData = [];
  // bar dimensions
  double barWidth = 20;
  double spaceBetweenBars = 15;

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
      (index) => SingleBar(
        x: index, 
        y: widget.monthlySummary[index]
      ),
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

  // scroll controller so it scrolls to the lastest month
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, 
      duration: const Duration(seconds: 1), 
      curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    // initialize bar data
    initializeBarData();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMaxValue(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: getBottomTitles,
                  reservedSize: 24,
                )),
              ),
              barGroups: barData.map(
                (data) => BarChartGroupData(
                  x: data.x, 
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.deepOrange.shade600,
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calculateMaxValue(),
                        color: Colors.grey.shade300,
                      )
                    ),
                  ],
                ),
              ).toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }
}

// get bottom titles
Widget getBottomTitles(double value, TitleMeta titleMeta) {
  const textstyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  final monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final monthIndex = value.toInt() % 12;
  final text = monthNames[monthIndex];

  return SideTitleWidget(axisSide: titleMeta.axisSide, child: Text(text, style: textstyle));
}
