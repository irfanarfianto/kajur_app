import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/keuangan/chart.dart';
import 'package:kajur_app/components/keuangan/showmodal_date.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/services/auth/keuangan/keuangan_services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final KeuanganService _service = KeuanganService();
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();

    _service.saldoTimestamp = DateTime.now();

    // Initialize the lists
    _service.incomeData = [];
    _service.expenseData = [];

    _service.selectedMonth = DateFormat('MMMM').format(DateTime.now());
    _service.selectedYear = DateFormat('yyyy').format(DateTime.now());

    // Fetch data for income table
    _service.fetchIncomeData(_service.selectedMonth, _service.selectedYear);

    // Fetch data for expense table
    _service.fetchExpenseData(_service.selectedMonth, _service.selectedYear);

    _service.onDataLoaded = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _service.fetchIncomeData(
                _service.selectedMonth,
                _service.selectedYear,
              );
              _service.fetchExpenseData(
                _service.selectedMonth,
                _service.selectedYear,
              );
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Skeletonizer(
              enabled:
                  _service.incomeData.isEmpty && _service.expenseData.isEmpty,
              child: Skeleton.leaf(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Col.secondaryColor,
                    border:
                        Border.all(color: const Color(0x309E9E9E), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Col.greyColor.withOpacity(.10),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${_service.selectedMonth} ${_service.selectedYear}',
                              style: Typo.titleTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                enableDrag: true,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: TimerPicker(
                                      selectedMonth: _service.selectedMonth,
                                      selectedYear: _service.selectedYear,
                                      onMonthChanged: (String newValue) {
                                        setState(() {
                                          _service.selectedMonth = newValue;
                                        });
                                        _service.fetchIncomeData(
                                          _service.selectedMonth,
                                          _service.selectedYear,
                                        );
                                        _service.fetchExpenseData(
                                          _service.selectedMonth,
                                          _service.selectedYear,
                                        );
                                      },
                                      onYearChanged: (String newValue) {
                                        setState(() {
                                          _service.selectedYear = newValue;
                                        });
                                        _service.fetchIncomeData(
                                          _service.selectedMonth,
                                          _service.selectedYear,
                                        );
                                        _service.fetchExpenseData(
                                          _service.selectedMonth,
                                          _service.selectedYear,
                                        );
                                      },
                                      onConfirm: () {
                                        if (mounted) {
                                          // Lakukan pembaruan logika Anda di sini
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.calendar_month,
                                color: Col.greyColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SfCartesianChartWidget(
                        incomeData: _service.incomeData,
                        expenseData: _service.expenseData,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                currencyFormat
                                    .format(_service.totalIncomeMonthly),
                                style: const TextStyle(
                                  color: Col.primaryColor,
                                  fontSize: 16,
                                  fontWeight: Fw.bold,
                                ),
                              ),
                              const Text(
                                'Pemasukan',
                                style: Typo.emphasizedBodyTextStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                currencyFormat
                                    .format(_service.totalExpenseMonthly),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Col.orangeAccent,
                                  fontSize: 16,
                                  fontWeight: Fw.bold,
                                ),
                              ),
                              const Text(
                                'Pengeluaran',
                                style: Typo.emphasizedBodyTextStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
