import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/animation/route/slide_up.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/components/riwayat_transaksi.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/chart.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/form_pemasukan.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/form_pengeluaran.dart';
import 'package:kajur_app/screens/home/tabs/keuangan/components/showmodal_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class KeuanganContent extends StatefulWidget {
  const KeuanganContent({super.key});

  @override
  State<KeuanganContent> createState() => _KeuanganContentState();
}

class _KeuanganContentState extends State<KeuanganContent> {
  late double totalSaldo = 0;
  late String timestampString = '';
  late StreamSubscription<DocumentSnapshot> _totalSaldoSubscription;
  late DateTime saldoTimestamp;
  late List<ChartData> incomeData;
  late List<ChartData> expenseData;
  double totalIncome = 0;
  double totalExpense = 0;
  late String selectedMonth;
  late String selectedYear;
  double totalIncomeMonthly = 0;
  double totalExpenseMonthly = 0;
  bool showBalance = false;

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
    fetchIncomeData(selectedMonth, selectedYear);

    // Fetch data for expense table
    fetchExpenseData(selectedMonth, selectedYear);
  }

  @override
  void dispose() {
    unsubscribeTotalSaldo();
    super.dispose();
  }

  void unsubscribeTotalSaldo() {
    _totalSaldoSubscription.cancel();
  }

  void listenToTotalSaldo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DocumentReference totalSaldoRef =
          FirebaseFirestore.instance.collection('saldo').doc('total');

      _totalSaldoSubscription = totalSaldoRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          double saldo = data['totalSaldo'] ?? 0;
          Timestamp timestamp = data['timestamp'];
          DateTime dateTime = timestamp.toDate();

          // Simpan total saldo ke dalam cache lokal
          prefs.setDouble('totalSaldo', saldo);
          prefs.setString('saldoTimestamp', dateTime.toString());

          setState(() {
            totalSaldo = saldo;
            saldoTimestamp = dateTime;
          });
        } else {
          print('Total saldo document does not exist.');
        }
      });
    } catch (error) {
      print('Error fetching total saldo: $error');
    }
  }

  void fetchIncomeData(String selectedMonth, String selectedYear) async {
    try {
      int selectedMonthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      int selectedYearInt = int.parse(selectedYear);

      // SharedPreferences prefs = await SharedPreferences.getInstance();

      // // Cek apakah data tersedia di cache lokal
      // if (prefs.containsKey('incomeData_$selectedMonth$selectedYear')) {
      //   // Jika ada, gunakan data dari cache lokal
      //   setState(() {
      //     incomeData = ChartData.decodeList(
      //         prefs.getStringList('incomeData_$selectedMonth$selectedYear')!);
      //     totalIncomeMonthly = prefs.getDouble(
      //             'totalIncomeMonthly_$selectedMonth$selectedYear') ??
      //         0;
      //   });
      //   return;
      // }

      CollectionReference incomeRef =
          FirebaseFirestore.instance.collection('income');

      List<ChartData> weeklyIncomeData = [];

      DateTime currentDate = DateTime(selectedYearInt, selectedMonthIndex, 1);
      DateTime endDate = DateTime(selectedYearInt, selectedMonthIndex + 1, 1);

      while (currentDate.isBefore(endDate)) {
        DateTime nextWeekStartDate =
            currentDate.add(const Duration(days: 7)).isBefore(endDate)
                ? currentDate.add(const Duration(days: 7))
                : endDate;

        QuerySnapshot querySnapshot = await incomeRef
            .where('date', isGreaterThanOrEqualTo: currentDate)
            .where('date', isLessThan: nextWeekStartDate)
            .get();

        double totalIncomeForWeek = 0;

        for (var document in querySnapshot.docs) {
          double incomeAmount = document['amount'] ?? 0;
          totalIncomeForWeek += incomeAmount;
        }

        String weekDateString =
            "${currentDate.day}-${nextWeekStartDate.subtract(const Duration(days: 1)).day}";
        weeklyIncomeData.add(ChartData(weekDateString, totalIncomeForWeek, 0));

        currentDate = nextWeekStartDate;
      }

      if (mounted) {
        setState(() {
          incomeData = weeklyIncomeData;
          totalIncomeMonthly = incomeData.fold(
              0, (previous, current) => previous + current.income);
        });

        // // Simpan data ke cache lokal
        // prefs.setStringList('incomeData_$selectedMonth$selectedYear',
        //     ChartData.encodeList(incomeData));
        // prefs.setDouble('totalIncomeMonthly_$selectedMonth$selectedYear',
        //     totalIncomeMonthly);
      }
    } catch (error) {
      print('Error fetching income data: $error');
    }
  }

  void fetchExpenseData(String selectedMonth, String selectedYear) async {
    try {
      int selectedMonthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      int selectedYearInt = int.parse(selectedYear);

      // SharedPreferences prefs = await SharedPreferences.getInstance();

      // // Cek apakah data pengeluaran bulanan sudah ada di cache
      // if (prefs.containsKey('expenseData_$selectedMonth$selectedYear')) {
      //   // Gunakan data dari cache lokal jika sudah ada
      //   setState(() {
      //     expenseData = ChartData.decodeList(
      //         prefs.getStringList('expenseData_$selectedMonth$selectedYear')!);
      //     totalExpenseMonthly = prefs.getDouble(
      //             'totalExpenseMonthly_$selectedMonth$selectedYear') ??
      //         0;
      //   });
      //   return;
      // }

      CollectionReference expenseRef =
          FirebaseFirestore.instance.collection('expenses');

      List<ChartData> weeklyExpenseData = [];

      DateTime currentDate = DateTime(selectedYearInt, selectedMonthIndex, 1);
      DateTime endDate = DateTime(selectedYearInt, selectedMonthIndex + 1, 1);

      while (currentDate.isBefore(endDate)) {
        DateTime nextWeekStartDate =
            currentDate.add(const Duration(days: 7)).isBefore(endDate)
                ? currentDate.add(const Duration(days: 7))
                : endDate;

        QuerySnapshot querySnapshot = await expenseRef
            .where('date', isGreaterThanOrEqualTo: currentDate)
            .where('date', isLessThan: nextWeekStartDate)
            .get();

        double totalExpenseForWeek = 0;

        for (var document in querySnapshot.docs) {
          double expenseAmount = document['amount'] ?? 0;
          totalExpenseForWeek += expenseAmount;
        }

        String weekDateString =
            "${currentDate.day}-${nextWeekStartDate.subtract(const Duration(days: 1)).day}";
        weeklyExpenseData
            .add(ChartData(weekDateString, 0, totalExpenseForWeek));

        currentDate = nextWeekStartDate;
      }

      if (mounted) {
        setState(() {
          expenseData = weeklyExpenseData;
          totalExpenseMonthly = expenseData.fold(
              0, (previous, current) => previous + current.expense);
        });
      }

      // // Simpan data pengeluaran bulanan ke dalam cache lokal
      // await prefs.setStringList('expenseData_$selectedMonth$selectedYear',
      //     ChartData.encodeList(weeklyExpenseData));
      // await prefs.setDouble('totalExpenseMonthly_$selectedMonth$selectedYear',
      //     totalExpenseMonthly);
    } catch (error) {
      print('Error fetching expense data: $error');
    }
  }

  void toggleShowBalance() {
    setState(() {
      showBalance = !showBalance;
    });
  }

  void updateChartDataAfterSubmission() {
    // Memperbarui data pemasukan
    fetchIncomeData(selectedMonth, selectedYear);

    // Memperbarui data pengeluaran
    fetchExpenseData(selectedMonth, selectedYear);
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
                            toggleShowBalance();
                          },
                          child: Text(
                            showBalance
                                ? currencyFormat.format(totalSaldo)
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
                            Navigator.push(
                                context,
                                SlideUpRoute(
                                    page: IncomeForm(
                                  updateChartDataCallback:
                                      updateChartDataAfterSubmission,
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
                                      updateChartDataAfterSubmission,
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
                        '$selectedMonth $selectedYear',
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
                                  selectedMonth: selectedMonth,
                                  selectedYear: selectedYear,
                                  onMonthChanged: (String newValue) {
                                    // Perbarui state selectedMonth
                                    setState(() {
                                      selectedMonth = newValue;
                                    });
                                    // Panggil kembali fungsi fetchIncomeData dan fetchExpenseData
                                    fetchIncomeData(
                                        selectedMonth, selectedYear);
                                    fetchExpenseData(
                                        selectedMonth, selectedYear);
                                  },
                                  onYearChanged: (String newValue) {
                                    // Perbarui state selectedYear
                                    setState(() {
                                      selectedYear = newValue;
                                    });
                                    // Panggil kembali fungsi fetchIncomeData dan fetchExpenseData
                                    fetchIncomeData(
                                        selectedMonth, selectedYear);
                                    fetchExpenseData(
                                        selectedMonth, selectedYear);
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
                    incomeData: incomeData,
                    expenseData: expenseData,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            currencyFormat.format(totalIncomeMonthly),
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
                            currencyFormat.format(totalExpenseMonthly),
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
                          onPressed: () {},
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
