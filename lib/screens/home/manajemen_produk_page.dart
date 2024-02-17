import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/components/activity/activity_widget.dart';
import 'package:kajur_app/components/menu%20button/menu.dart';
import 'package:kajur_app/components/produk/total_produk_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManajemenProdukContent extends StatefulWidget {
  final String userRole;

  const ManajemenProdukContent(
      {super.key, required this.userRole}); // Ubah konstruktor

  @override
  State<ManajemenProdukContent> createState() => _ManajemenProdukContentState();
}

class _ManajemenProdukContentState extends State<ManajemenProdukContent> {
  late String _userRole;
  // final KeuanganService _service = KeuanganService();
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // _service.listenToTotalSaldo();
    _userRole = widget.userRole;
    // // Initialize the lists
    // _service.incomeData = [];
    // _service.expenseData = [];
    // _service.saldoTimestamp = DateTime.timestamp();

    // _service.selectedMonth = DateFormat('MMMM').format(DateTime.now());
    // _service.selectedYear = DateFormat('yyyy').format(DateTime.now());

    // // Fetch data for income table
    // _service.fetchIncomeData(_service.selectedMonth, _service.selectedYear);

    // // Fetch data for expense table
    // _service.fetchExpenseData(_service.selectedMonth, _service.selectedYear);

    // _service.onDataLoaded = () {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // };
  }

  // @override
  // void dispose() {
  //   _service.unsubscribeTotalSaldo();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // TotalSaldo(service: _service, currencyFormat: currencyFormat),
          const SizedBox(height: 20),
          buildTotalProductsWidget(context),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                buildMenuWidget(
                    context, _userRole), // Gunakan _userRole di sini
                const SizedBox(height: 20),
                buildRecentActivityWidget(context),
              ],
            ),
          ),
          Skeleton.keep(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('~ Segini dulu yaa ~',
                      style: Typo.subtitleTextStyle),
                  Image.asset(
                    'images/gambar.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
