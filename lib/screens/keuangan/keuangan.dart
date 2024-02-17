import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/animation/route/slide_left.dart';
import 'package:kajur_app/animation/route/slide_up.dart';
import 'package:kajur_app/components/keuangan/riwayat_transaksi.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas_page.dart';
import 'package:kajur_app/components/keuangan/chart.dart';
import 'package:kajur_app/screens/keuangan/form_pemasukan_page.dart';
import 'package:kajur_app/screens/keuangan/form_pengeluaran_page.dart';
import 'package:kajur_app/components/keuangan/showmodal_date.dart';
import 'package:kajur_app/services/auth/keuangan/keuangan_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class KeuanganContent extends StatefulWidget {
  const KeuanganContent({super.key});

  @override
  State<KeuanganContent> createState() => _KeuanganContentState();
}

class _KeuanganContentState extends State<KeuanganContent> {
  final KeuanganService _service = KeuanganService();

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
  }

  @override
  void dispose() {
    _service.unsubscribeTotalSaldo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              alignment: Alignment.topCenter,
              height: 200,
              width: 375,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Col.secondaryColor,
                border: Border.all(color: const Color(0x309E9E9E), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Col.greyColor.withOpacity(.10),
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: 375,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Col.primaryColor,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Saldo',
                              style: TextStyle(
                                  fontSize: 18.0, color: Col.whiteColor),
                            ),
                            Icon(Icons.copy_outlined, color: Col.whiteColor)
                          ],
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            _service.toggleShowBalance();
                          },
                          child: Text(
                            _service.showBalance
                                ? currencyFormat.format(_service.totalSaldo)
                                : 'Rp *****',
                            style: const TextStyle(
                              fontSize: 28.0,
                              color: Col.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '*Update ${DateFormat('dd MMMM yyyy HH:mm', 'id').format(_service.saldoTimestamp)}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Col.whiteColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlideUpRoute(
                                    page: IncomeForm(
                                  updateChartDataCallback:
                                      _service.updateChartDataAfterSubmission,
                                )));
                          },
                          icon: const Icon(Icons.south_west),
                          label: const Text('Catat pemasukan')),
                      TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                SlideUpRoute(
                                    page: ExpenseForm(
                                  updateChartDataCallback:
                                      _service.updateChartDataAfterSubmission,
                                )));
                          },
                          icon: const Icon(Icons.north_east),
                          label: const Text('Catat pengeluaran')),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Col.secondaryColor,
                border: Border.all(color: const Color(0x309E9E9E), width: 1),
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
                  Text(
                    'Tracking',
                    style: Typo.titleTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_service.selectedMonth $_service.selectedYear',
                        style: Typo.emphasizedBodyTextStyle,
                      ),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: TimerPicker(
                                  selectedMonth: _service.selectedMonth,
                                  selectedYear: _service.selectedYear,
                                  onMonthChanged: (String newValue) {
                                    // Perbarui state selectedMonth
                                    setState(() {
                                      _service.selectedMonth = newValue;
                                    });
                                    // Panggil kembali fungsi fetchIncomeData dan fetchExpenseData
                                    _service.fetchIncomeData(
                                        _service.selectedMonth,
                                        _service.selectedYear);
                                    _service.fetchExpenseData(
                                        _service.selectedMonth,
                                        _service.selectedYear);
                                  },
                                  onYearChanged: (String newValue) {
                                    // Perbarui state selectedYear
                                    setState(() {
                                      _service.selectedYear = newValue;
                                    });
                                    // Panggil kembali fungsi fetchIncomeData dan fetchExpenseData
                                    _service.fetchIncomeData(
                                        _service.selectedMonth,
                                        _service.selectedYear);
                                    _service.fetchExpenseData(
                                        _service.selectedMonth,
                                        _service.selectedYear);
                                  },
                                  onConfirm: () {
                                    if (mounted) {
                                      // Lakukan pembaruan logika Anda di sini
                                    }
                                    Navigator.of(context)
                                        .pop(); // Tutup bottom sheet setelah konfirmasi
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
                            currencyFormat.format(_service.totalIncomeMonthly),
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
                            currencyFormat.format(_service.totalExpenseMonthly),
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Col.secondaryColor,
                border: Border.all(color: const Color(0x309E9E9E), width: 1),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: Typo.titleTextStyle,
                        ),
                        TextButton(
                          onPressed: () {
                            SlideLeftRoute(page: const AllActivitiesPage());
                          },
                          child: const Text(
                            'Lihat semua',
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TransactionHistory()
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
