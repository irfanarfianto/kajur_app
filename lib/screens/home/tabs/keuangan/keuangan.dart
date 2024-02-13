import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/animation/route/slide_up.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/form_pemasukan.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/form_pengeluaran.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class KeuanganContent extends StatefulWidget {
  const KeuanganContent({super.key});

  @override
  State<KeuanganContent> createState() => _KeuanganContentState();
}

class _KeuanganContentState extends State<KeuanganContent> {
  late double totalSaldo = 0;
  String timestampString = '';
  late StreamSubscription<DocumentSnapshot> _totalSaldoSubscription;
  late DateTime saldoTimestamp;
  late List<ChartData> incomeData;
  late List<ChartData> expenseData;
  double totalIncome = 0; // Define totalIncome as a class member
  double totalExpense = 0;
  late String selectedMonth;
  late String selectedYear;

  @override
  void initState() {
    super.initState();
    listenToTotalSaldo();
    saldoTimestamp = DateTime.now();

    // Initialize the lists
    incomeData = [];
    expenseData = [];

    selectedMonth = DateFormat('MMMM').format(DateTime.now());
    selectedYear = DateFormat('yyyy').format(DateTime.now());

    // Fetch data for income table
    fetchIncomeData();

    // Fetch data for expense table
    fetchExpenseData();
  }

  @override
  void dispose() {
    // Hentikan langganan saat widget di dispose untuk mencegah memory leak
    unsubscribeTotalSaldo();
    super.dispose();
  }

  void listenToTotalSaldo() {
    try {
      DocumentReference totalSaldoRef =
          FirebaseFirestore.instance.collection('saldo').doc('total');

      // Langganan perubahan dokumen 'total' pada koleksi 'saldo'
      _totalSaldoSubscription = totalSaldoRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          double saldo = data['totalSaldo'] ?? 0;
          Timestamp timestamp = data['timestamp']; // Ambil properti waktu
          DateTime dateTime = timestamp.toDate(); // Konversi ke tipe DateTime
          setState(() {
            totalSaldo = saldo;
            saldoTimestamp = dateTime; // Simpan waktu saldo
          });
        } else {
          print('Total saldo document does not exist.');
        }
      });
    } catch (error) {
      print('Error fetching total saldo: $error');
    }
  }

  void unsubscribeTotalSaldo() {
    // Check if the subscription is active before canceling it
    _totalSaldoSubscription.cancel();
  }

  void fetchIncomeData() {
    try {
      // Mendapatkan tanggal hari ini
      DateTime today = DateTime.now();

      // Mendapatkan tanggal 7 hari yang lalu
      DateTime sevenDaysAgo = today.subtract(const Duration(days: 7));

      CollectionReference incomeRef =
          FirebaseFirestore.instance.collection('income');

      // Fetch data untuk setiap minggu dalam rentang waktu
      for (int i = 0; i < 7; i++) {
        DateTime startDate = sevenDaysAgo.add(Duration(days: i));
        DateTime endDate = startDate.add(const Duration(days: 1));

        double totalIncome = 0;

        incomeRef
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThan: endDate)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((DocumentSnapshot document) {
            totalIncome += document['amount'] ?? 0;
          });

          String weekDateString =
              "${startDate.day}-${endDate.day}"; // Format rentang tanggal
          setState(() {
            incomeData.add(ChartData(weekDateString, totalIncome, 0));
          });
        });
      }
    } catch (error) {
      print('Error fetching income data: $error');
    }
  }

  void fetchExpenseData() {
    try {
      // Mendapatkan tanggal hari ini
      DateTime today = DateTime.now();

      // Mendapatkan tanggal 7 hari yang lalu
      DateTime sevenDaysAgo = today.subtract(const Duration(days: 7));

      CollectionReference expenseRef =
          FirebaseFirestore.instance.collection('expenses');

      // Fetch data untuk setiap minggu dalam rentang waktu
      for (int i = 0; i < 7; i++) {
        DateTime startDate = sevenDaysAgo.add(Duration(days: i));
        DateTime endDate = startDate.add(const Duration(days: 1));

        double totalExpense = 0;

        expenseRef
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThan: endDate)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((DocumentSnapshot document) {
            totalExpense += double.parse(document['amount'] ?? '0');
          });

          String weekDateString = "${startDate.day}-${endDate.day}";
          setState(() {
            expenseData.add(ChartData(weekDateString, 0, totalExpense));
          });
        });
      }
    } catch (error) {
      print('Error fetching expense data: $error');
    }
  }

  Widget _buildMonthYearDropdown() {
    return Row(
      children: [
        DropdownButton<String>(
          value: selectedMonth,
          onChanged: (String? newValue) {
            setState(() {
              selectedMonth = newValue!;
            });
          },
          items: <String>[
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedYear,
          onChanged: (String? newValue) {
            setState(() {
              selectedYear = newValue!;
            });
          },
          items: <String>[
            '2022', '2023', '2024' // Add more years as needed
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    alignment: Alignment.topCenter,
                    height: 200,
                    width: 380,
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
                      children: [
                        Container(
                          height: 150,
                          width: 380,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Saldo',
                                    style: TextStyle(
                                        fontSize: 18.0, color: Col.whiteColor),
                                  ),
                                  Icon(Icons.copy_outlined,
                                      color: Col.whiteColor)
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                currencyFormat.format(totalSaldo),
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  color: Col.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '*Update ${DateFormat('dd MMMM yyyy HH:mm', 'id').format(saldoTimestamp)}',
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
                                  Navigator.push(context,
                                      SlideUpRoute(page: IncomeForm()));
                                },
                                icon: const Icon(Icons.south_west),
                                label: const Text('Catat pemasukan')),
                            TextButton.icon(
                                onPressed: () {
                                  Navigator.push(context,
                                      SlideUpRoute(page: ExpenseForm()));
                                },
                                icon: const Icon(Icons.north_east),
                                label: const Text('Catat pengeluaran')),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: 380,
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
                                  'Total Saldo Dana',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Col.whiteColor),
                                ),
                                Icon(Icons.copy_outlined, color: Col.whiteColor)
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              currencyFormat.format(
                                  1500000), // Contoh penggunaan format mata uang
                              style: const TextStyle(
                                fontSize: 28.0,
                                color: Col.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '*Update terakhir ',
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Col.whiteColor,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tracking',
                        style: Typo.titleTextStyle,
                      ),
                      _buildMonthYearDropdown()
                    ],
                  ),
                  const SizedBox(height: 8),
                  SfCartesianChart(
                    borderColor: Colors.white,
                    primaryXAxis: const CategoryAxis(
                      borderWidth: 0,
                      majorGridLines: MajorGridLines(width: 0),
                      majorTickLines: MajorTickLines(size: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: AxisLine(
                        color: Colors.white.withOpacity(.5),
                      ),
                      numberFormat: NumberFormat.compactCurrency(
                          locale: 'id', symbol: ''),
                      labelFormat: '{value}',
                      majorGridLines: const MajorGridLines(
                        width: 1, // Atur lebar garis
                        dashArray: <double>[3, 3],
                      ),
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    series: <ColumnSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                        dataSource: incomeData,
                        xValueMapper: (ChartData sales, _) => sales.week,
                        yValueMapper: (ChartData sales, _) => sales.totalIncome,
                        name: 'Pemasukan',
                        spacing: 0.1,
                        width: 0.5,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.1, 0.9],
                            tileMode: TileMode.clamp,
                            colors: [
                              Colors.blueAccent,
                              Colors.blueAccent.withOpacity(.2),
                            ]),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.elliptical(6, 6),
                          topRight: Radius.elliptical(6, 6),
                        ),
                      ),
                      ColumnSeries<ChartData, String>(
                        dataSource: expenseData,
                        xValueMapper: (ChartData sales, _) => sales.week,
                        yValueMapper: (ChartData sales, _) =>
                            sales.totalExpense,
                        name: 'Pemasukan',
                        spacing: 0.1,
                        width: 0.5,
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.1, 0.9],
                            tileMode: TileMode.clamp,
                            colors: [
                              Colors.orangeAccent,
                              Colors.orangeAccent.withOpacity(.2),
                            ]),
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
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     Column(
                  //       children: [
                  //         Text(
                  //           currencyFormat.format(getTotalIncome()),
                  //           style: const TextStyle(
                  //               color: Col.primaryColor,
                  //               fontSize: 16,
                  //               fontWeight: Fw.bold),
                  //         ),
                  //         const Text(
                  //           'Pemasukan',
                  //           style: Typo.emphasizedBodyTextStyle,
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       children: [
                  //         Text(
                  //           currencyFormat.format(getTotalExpense()),
                  //           textAlign: TextAlign.center,
                  //           style: const TextStyle(
                  //               color: Col.orangeAccent,
                  //               fontSize: 16,
                  //               fontWeight: Fw.bold),
                  //         ),
                  //         const Text(
                  //           'Pengeluaran',
                  //           style: Typo.emphasizedBodyTextStyle,
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
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
                          onPressed: () {},
                          child: const Text(
                            'Lihat semua',
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(
                      4,
                      (index) => Skeletonizer(
                        enabled: true,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Skeleton.leaf(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ),
                              title: Container(
                                width: 200,
                                height: 20,
                                color: Colors.grey[300],
                              ),
                              subtitle: Container(
                                width: 100,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: Colors.grey[300],
                                    size: 15,
                                  ),
                                  Container(
                                    width: 60,
                                    height: 16,
                                    color: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                            if (index <
                                2) // Don't add Divider after the last item
                              Divider(
                                thickness: 1,
                                color: Colors.grey[300],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.week, this.totalIncome, this.totalExpense);
  final String week;
  final double totalIncome;
  final double totalExpense;
}
