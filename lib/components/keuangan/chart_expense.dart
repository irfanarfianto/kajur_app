import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SfDoughnutChartWidget extends StatelessWidget {
  final List<ExpenseChartData> expenseData;

  const SfDoughnutChartWidget({
    super.key,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    return expenseData.isEmpty
        ? const SizedBox(
            height: 150,
            child: Center(
              child: Text('Belum ada datanya'),
            ),
          )
        : SfCircularChart(
            centerX: '50%',
            series: <DoughnutSeries<ExpenseChartData, String>>[
              DoughnutSeries<ExpenseChartData, String>(
                radius: '60%',
                innerRadius: '60%',
                animationDuration: 0,
                explodeOffset: '10%',
                explode: true,
                explodeIndex: 0,
                dataSource: expenseData,
                xValueMapper: (ExpenseChartData data, _) => data.category,
                yValueMapper: (ExpenseChartData data, _) => data.amount,
                dataLabelMapper: (ExpenseChartData data, _) =>
                    data.formattedExpense,
                // Atur warna grafik untuk setiap kategori
                pointColorMapper: (ExpenseChartData data, _) {
                  if (data.category == 'Belanja Pokok') {
                    return Col.primaryColor;
                  } else if (data.category == 'Bagi Hasil') {
                    return Col.greenAccent;
                  } else if (data.category == 'Perkap') {
                    return Col.purpleAccent;
                  } else if (data.category == 'Transportasi') {
                    return Col.orangeAccent;
                  }
                  // Kembalikan warna default jika kategori tidak dikenali
                  return Colors.grey;
                },
                cornerStyle: CornerStyle.bothFlat,
                enableTooltip: true,
                legendIconType: LegendIconType.circle,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                  ),
                  textStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: const TextStyle(fontSize: 10),
              position: LegendPosition.top,
              orientation: LegendItemOrientation.horizontal,
              borderColor: Colors.transparent,
              borderWidth: 0,
              toggleSeriesVisibility: false,
              backgroundColor: Colors.transparent,
              legendItemBuilder: (name, series, point, index) {
                final color = expenseData[index].category == 'Belanja Pokok'
                    ? Col.primaryColor
                    : expenseData[index].category == 'Bagi Hasil'
                        ? Col.greenAccent
                        : expenseData[index].category == 'Perkap'
                            ? Col.purpleAccent
                            : expenseData[index].category == 'Transportasi'
                                ? Col.orangeAccent
                                : Colors.grey;

                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(name),
                  ],
                );
              },
            ),
          );
  }
}

class ExpenseChartData {
  String category;
  double amount;

  ExpenseChartData({required this.category, required this.amount});

  String get formattedExpense {
    final formatter = NumberFormat.compactCurrency(
        locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  static List<String> encodeList(List<ExpenseChartData> list) {
    return list.map((data) => '${data.category},${data.amount}').toList();
  }

  static List<ExpenseChartData> decodeList(List<String> list) {
    return list.map((String item) {
      List<String> parts = item.split(',');
      return ExpenseChartData(
        category: parts[0],
        amount: double.parse(parts[1]),
      );
    }).toList();
  }
}
