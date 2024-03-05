import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/keuangan/chart_expense.dart';
import 'package:kajur_app/components/keuangan/chart_income_expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeuanganService {
  void Function()? onDataLoaded;
  late double totalSaldo = 0;
  int monthlyActivityCount = 0;
  List<double> pendapatanPerBulan = [];
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
  List<ExpenseChartData> monthlyExpenseData = [];
  double totalExpenseForMonth = 0;
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

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
          if (onDataLoaded != null) {
            onDataLoaded!(); // Panggil callback
          }
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

  Future<void> fetchIncomeData(
      String selectedMonth, String selectedYear) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int selectedMonthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      int selectedYearInt = int.parse(selectedYear);

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

      // Perbarui cache lokal setelah mendapatkan data baru dari Firestore
      await prefs.setStringList('incomeData_$selectedMonth$selectedYear',
          ChartData.encodeList(incomeData));
      await prefs.setDouble(
          'totalIncomeMonthly_$selectedMonth$selectedYear', totalIncomeMonthly);

      if (onDataLoaded != null) {
        onDataLoaded!(); // Panggil callback
      }
    } catch (error) {
      print('Error fetching income data: $error');
    }
  }

  Future<void> fetchExpenseData(
      String selectedMonth, String selectedYear) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int selectedMonthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      int selectedYearInt = int.parse(selectedYear);

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

      // Perbarui cache lokal setelah mendapatkan data baru dari Firestore
      await prefs.setStringList('expenseData_$selectedMonth$selectedYear',
          ChartData.encodeList(expenseData));
      await prefs.setDouble('totalExpenseMonthly_$selectedMonth$selectedYear',
          totalExpenseMonthly);

      if (onDataLoaded != null) {
        onDataLoaded!(); // Panggil callback
      }
    } catch (error, stackTrace) {
      print(
          stackTrace); // Cetak stack trace untuk mendapatkan detail lebih lanjut
    }
  }

  void toggleShowBalance() {
    showBalance = !showBalance;
    if (onDataLoaded != null) {
      onDataLoaded!(); // Panggil callback
    }
  }

  void updateChartDataAfterSubmission() {
    // Memperbarui data pemasukan
    fetchIncomeData(selectedMonth, selectedYear);

    // Memperbarui data pengeluaran
    fetchExpenseData(selectedMonth, selectedYear);

    if (onDataLoaded != null) {
      onDataLoaded!(); // Panggil callback
    }
  }

  Future<int> fetchMonthlyActivityCount(
      String selectedMonth, String selectedYear) async {
    try {
      int selectedMonthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      int selectedYearInt = int.parse(selectedYear);

      CollectionReference activityLogRef =
          FirebaseFirestore.instance.collection('activity_log');

      DateTime startDate = DateTime(selectedYearInt, selectedMonthIndex, 1);
      DateTime endDate = DateTime(selectedYearInt, selectedMonthIndex + 1, 1);

      QuerySnapshot querySnapshot = await activityLogRef
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThan: endDate)
          .get();

      int monthlyActivityCount = querySnapshot.docs.length;

      if (onDataLoaded != null) {
        onDataLoaded!(); // Panggil callback
      }

      return monthlyActivityCount;
    } catch (error) {
      print('Error fetching monthly activity count: $error');
      return 0;
    }
  }
}
