import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/keuangan.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:kajur_app/design/system.dart';

class KeuanganChart extends StatelessWidget {
  final List<ChartData> chartData;
  final String selectedMonth;
  final int selectedYear;

  const KeuanganChart({
    Key? key,
    required this.chartData,
    required this.selectedMonth,
    required this.selectedYear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tracking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SfCartesianChart(
          primaryXAxis: const CategoryAxis(
            edgeLabelPlacement: EdgeLabelPlacement.none,
            borderWidth: 0,
            majorGridLines: MajorGridLines(width: 0),
            majorTickLines: MajorTickLines(size: 0),
          ),
          primaryYAxis: NumericAxis(
            numberFormat:
                NumberFormat.compactCurrency(locale: 'id', symbol: ''),
            labelFormat: '{value}',
            majorGridLines: const MajorGridLines(
              width: 1,
              dashArray: <double>[3, 3],
            ),
            majorTickLines: const MajorTickLines(size: 0),
          ),
          series: <ColumnSeries<ChartData, String>>[
            ColumnSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData sales, _) => sales.week,
              yValueMapper: (ChartData sales, _) => sales.totalIncome,
              name: 'Pemasukan',
              spacing: 0.1,
              width: 0.5,
              color: Col.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(6, 6),
                topRight: Radius.elliptical(6, 6),
              ),
            ),
            ColumnSeries<ChartData, String>(
              dataSource: chartData,
              xValueMapper: (ChartData sales, _) => sales.week,
              yValueMapper: (ChartData sales, _) => sales.totalExpense,
              name: 'Pengeluaran',
              spacing: 0.1,
              width: 0.5,
              color: Col.orangeAccent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(6, 6),
                topRight: Radius.elliptical(6, 6),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedMonth,
              onChanged: (String? newValue) {
                // Implementasi logika pembaruan data
              },
              items: [],
              // Item dropdown untuk bulan
            ),
            DropdownButton<int>(
              value: selectedYear,
              onChanged: (int? newValue) {
                // Implementasi logika pembaruan data
              },
              items: [],
              // Item dropdown untuk tahun
            ),
          ],
        ),
      ],
    );
  }
}
