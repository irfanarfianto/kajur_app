import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class SfCartesianChartWidget extends StatelessWidget {
  final List<ChartData> incomeData;
  final List<ChartData> expenseData;

  const SfCartesianChartWidget({
    super.key,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: const EdgeInsets.all(0),
      plotAreaBorderWidth: 0,
      borderColor: Colors.white,
      borderWidth: 0,
      backgroundColor: Colors.transparent,
      loadMoreIndicatorBuilder: (context, direction) => SizedBox.shrink(),
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(
          fontSize: 10,
        ),
        borderWidth: 0,
        majorGridLines: MajorGridLines(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(
          width: 0,
        ),
        desiredIntervals: 5,
        edgeLabelPlacement: EdgeLabelPlacement.none,
        numberFormat: NumberFormat.compactCurrency(locale: 'id', symbol: ''),
        labelFormat: '{value}',
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: const MajorGridLines(
          width: 1,
          dashArray: <double>[3, 3],
        ),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: <ColumnSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: incomeData,
          xValueMapper: (ChartData sales, _) => sales.weekDateString,
          yValueMapper: (ChartData sales, _) => sales.income,
          name: 'Pemasukan',
          spacing: 0.1,
          width: 0.8,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.9],
            tileMode: TileMode.clamp,
            colors: [
              Colors.blueAccent,
              Colors.blueAccent.withOpacity(.2),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.elliptical(6, 6),
            topRight: Radius.elliptical(6, 6),
          ),
        ),
        ColumnSeries<ChartData, String>(
          dataSource: expenseData,
          xValueMapper: (ChartData sales, _) => sales.weekDateString,
          yValueMapper: (ChartData sales, _) => sales.expense,
          name: 'Pengeluaran',
          spacing: 0.1,
          width: 0.8,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.9],
            tileMode: TileMode.clamp,
            colors: [
              Colors.orangeAccent,
              Colors.orangeAccent.withOpacity(.2),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.elliptical(6, 6),
            topRight: Radius.elliptical(6, 6),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y',
      ),
    );
  }
}

class ChartData {
  final String weekDateString;
  final double income;
  final double expense;

  ChartData(this.weekDateString, this.income, this.expense);

  // Method to encode a list of ChartData objects into a list of strings
  static List<String> encodeList(List<ChartData> list) {
    return list
        .map((data) => '${data.weekDateString},${data.income},${data.expense}')
        .toList();
  }

  // Method to decode a list of strings into a list of ChartData objects
  static List<ChartData> decodeList(List<String> list) {
    return list.map((String item) {
      List<String> parts = item.split(',');
      return ChartData(
        parts[0], // weekDateString
        double.parse(parts[1]), // income
        double.parse(parts[2]), // expense
      );
    }).toList();
  }
}
