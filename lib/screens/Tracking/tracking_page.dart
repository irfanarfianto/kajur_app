import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/keuangan/chart.dart';
import 'package:kajur_app/components/keuangan/showmodal_date.dart';
import 'package:kajur_app/services/auth/produk/produk_services.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/services/auth/keuangan/keuangan_services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final ProdukService _produkService = ProdukService();
  final KeuanganService _service = KeuanganService();
  final currencyFormat = NumberFormat.compactCurrency(
      locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  String totalProdukText = '';
  String makananProdukText = '';
  String minumanProdukText = '';

  @override
  void initState() {
    super.initState();
    _service.listenToTotalSaldo();
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

    _produkService.getProductCountByCategory(
        (int totalProduk, int makananCount, int minumanCount) {
      setState(() {
        totalProdukText = totalProduk.toString();
        makananProdukText = makananCount.toString();
        minumanProdukText = minumanCount.toString();
      });
    });
  }

  @override
  void dispose() {
    _service.unsubscribeTotalSaldo();
    super.dispose();
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
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 1.3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(10),
              children: [
                Container(
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
                      const Row(
                        children: [
                          Text('Total Saldo'),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: null,
                            child: FaIcon(FontAwesomeIcons.circleExclamation,
                                color: Col.greyColor, size: 10),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(currencyFormat.format(_service.totalSaldo),
                          style: Typo.headingTextStyle),
                      Text(
                          DateFormat('dd MMM yyyy HH:mm', 'id')
                              .format(_service.saldoTimestamp),
                          style: Typo.emphasizedBodyTextStyle),
                    ],
                  ),
                ),
                Skeletonizer(
                  enabled: _service.incomeData.isEmpty &&
                      _service.expenseData.isEmpty,
                  child: Skeleton.leaf(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Col.secondaryColor,
                        border: Border.all(
                            color: const Color(0x309E9E9E), width: 1),
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
                          const Text('Pendapatan Bulan ini'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            (_service.totalIncomeMonthly == 0 &&
                                    _service.totalExpenseMonthly == 0)
                                ? 'Rp '
                                : currencyFormat.format(
                                    _service.totalIncomeMonthly -
                                        _service.totalExpenseMonthly),
                            style: TextStyle(
                              fontSize: 20.0,
                              color: (_service.totalIncomeMonthly -
                                          _service.totalExpenseMonthly >=
                                      0)
                                  ? Col.greenAccent
                                  : Col.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (_service.totalIncomeMonthly != 0 ||
                              _service.totalExpenseMonthly != 0)
                            Row(
                              children: [
                                Icon(
                                  (_service.totalIncomeMonthly -
                                              _service.totalExpenseMonthly >=
                                          0)
                                      ? FontAwesomeIcons.arrowUp
                                      : FontAwesomeIcons.arrowDown,
                                  size: 16,
                                  color: (_service.totalIncomeMonthly -
                                              _service.totalExpenseMonthly >=
                                          0)
                                      ? Col.greenAccent
                                      : Col.redAccent,
                                ),
                                Text(
                                  (_service.totalIncomeMonthly == 0 &&
                                          _service.totalExpenseMonthly == 0)
                                      ? ''
                                      : '(${((_service.totalIncomeMonthly - _service.totalExpenseMonthly) / _service.totalIncomeMonthly * 100).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: (_service.totalIncomeMonthly -
                                                _service.totalExpenseMonthly >=
                                            0)
                                        ? Col.greenAccent
                                        : Col.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
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
                      const Text('Total Produk'),
                      const SizedBox(height: 10),
                      Text(totalProdukText, style: Typo.headingTextStyle),
                      Text('Makanan $makananProdukText',
                          style: Typo.emphasizedBodyTextStyle),
                      Text('Minuman $minumanProdukText',
                          style: Typo.emphasizedBodyTextStyle),
                    ],
                  ),
                )
              ],
            ),
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
