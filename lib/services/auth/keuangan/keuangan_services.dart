import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/keuangan/chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeuanganService {
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

  Future<void> listenToTotalSaldo() async {
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

          totalSaldo = saldo;
          saldoTimestamp = dateTime;
        } else {
          print('Total saldo document does not exist.');
        }
      });
    } catch (error) {
      print('Error fetching total saldo: $error');
    }
  }

  void unsubscribeTotalSaldo() {
    _totalSaldoSubscription.cancel();
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

      incomeData = weeklyIncomeData;
      totalIncomeMonthly =
          incomeData.fold(0, (previous, current) => previous + current.income);

      // // Simpan data ke cache lokal
      // prefs.setStringList('incomeData_$selectedMonth$selectedYear',
      //     ChartData.encodeList(incomeData));
      // prefs.setDouble('totalIncomeMonthly_$selectedMonth$selectedYear',
      //     totalIncomeMonthly);
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

      expenseData = weeklyExpenseData;
      totalExpenseMonthly = expenseData.fold(
          0, (previous, current) => previous + current.expense);

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
    showBalance = !showBalance;
  }

  void updateChartDataAfterSubmission() {
    // Memperbarui data pemasukan
    fetchIncomeData(selectedMonth, selectedYear);

    // Memperbarui data pengeluaran
    fetchExpenseData(selectedMonth, selectedYear);
  }
}
