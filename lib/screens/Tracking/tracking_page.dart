import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/keuangan/chart_expense.dart';
import 'package:kajur_app/components/keuangan/chart_income_expense.dart';
import 'package:kajur_app/components/keuangan/daftar_user.dart';
import 'package:kajur_app/components/keuangan/keterangan_saldo.dart';
import 'package:kajur_app/components/keuangan/showmodal_date.dart';
import 'package:kajur_app/services/keuangan/keuangan_services.dart';
import 'package:kajur_app/services/produk/produk_services.dart';
import 'package:kajur_app/utils/design/system.dart';
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
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  int monthlyActivityCount = 0;

  String totalProdukText = '';
  String makananProdukText = '';
  String minumanProdukText = '';

  List<Map<String, dynamic>> userProfiles = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _service.listenToTotalSaldo();
    _service.saldoTimestamp = DateTime.now();
    _service.incomeData = [];
    _service.expenseData = [];
    _service.monthlyExpenseData = [];
    _service.selectedMonth = DateFormat('MMMM').format(DateTime.now());
    _service.selectedYear = DateFormat('yyyy').format(DateTime.now());

    _service.fetchIncomeData(
      _service.selectedMonth,
      _service.selectedYear,
    );
    _service.fetchExpenseData(
      _service.selectedMonth,
      _service.selectedYear,
    );

    _service
        .fetchMonthlyActivityCount(
            _service.selectedMonth, _service.selectedYear)
        .then((count) {
      setState(() {
        monthlyActivityCount = count;
      });
    });

    _service.onDataLoaded = () {
      if (mounted) {
        setState(() {});
      }
    };

    _produkService.getProductCountByCategory(
      (int totalProduk, int makananCount, int minumanCount) {
        if (mounted) {
          setState(() {
            totalProdukText = totalProduk.toString();
            makananProdukText = makananCount.toString();
            minumanProdukText = minumanCount.toString();
          });
        }
      },
    );
    _getUserProfiles();
  }

  Future<void> _getUserProfiles() async {
    List<Map<String, dynamic>> profiles =
        await _produkService.getAllUserProfiles();
    setState(() {
      userProfiles = profiles;
    });
  }

  @override
  void dispose() {
    _service.unsubscribeTotalSaldo();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Tambahkan logika untuk memuat ulang data di sini
    // Misalnya, panggil _initializeData untuk mengambil data baru
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: const Text('Statistik Bulanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RefreshIndicator(
            displacement: 50,
            edgeOffset: 15,
            onRefresh:
                _refreshData, // Panggil fungsi _refreshData saat pull to refresh
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ringkasan statistik',
                              style: Typo.titleTextStyle),
                          Text(
                            'Bulan ${_service.selectedMonth} ${_service.selectedYear}',
                            style: Typo.bodyTextStyle.copyWith(
                              color: Col.greyColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                                      MediaQuery.of(context).size.height * 0.4,
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
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Col.greyColor,
                          ))
                    ],
                  ),
                  Divider(
                    thickness: 1,
                    color: Col.greyColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 10),
                  _buildGridView(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildChartContainer(),
                  const SizedBox(height: 20),
                  _buildChartExpenseContainer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 1.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        // _buildTotalSaldoContainer(),
        _buildPendapatanBulananContainer(),
        _buildTotalProdukContainer(),
        _buildAktivitasContainer(),
        _buildPengurusContainer(),
      ],
    );
  }

  Widget _buildTotalSaldoContainer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
            children: [
              const Text('Total Saldo'),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    enableDrag: true,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: const KeteranganSaldo(),
                      );
                    },
                  );
                },
                child: const FaIcon(
                  FontAwesomeIcons.circleExclamation,
                  color: Col.greyColor,
                  size: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(currencyFormat.format(_service.totalSaldo),
              style: Typo.headingTextStyle),
          Text(
            DateFormat('dd/MM/yyyy HH:mm WIB', 'id')
                .format(_service.saldoTimestamp),
            style: Typo.emphasizedBodyTextStyle.copyWith(
              color: Col.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendapatanBulananContainer() {
    return Skeletonizer(
      enabled: _service.incomeData.isEmpty && _service.expenseData.isEmpty,
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
              Text('Pendapatan Bersih',
                  style: Typo.bodyTextStyle.copyWith(fontWeight: Fw.medium)),
              Text(
                (_service.totalIncomeMonthly == 0 &&
                        _service.totalExpenseMonthly == 0)
                    ? 'Rp 0'
                    : currencyFormat.format(_service.totalIncomeMonthly -
                        _service.totalExpenseMonthly),
                style: TextStyle(
                  fontSize: 18.0,
                  color: (_service.totalIncomeMonthly -
                              _service.totalExpenseMonthly >=
                          0)
                      ? Col.greenAccent
                      : Col.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_service.totalIncomeMonthly != 0 ||
                  _service.totalExpenseMonthly != 0)
                Text(
                  (_service.totalIncomeMonthly == 0)
                      ? '0.00%'
                      : '${((_service.totalIncomeMonthly - _service.totalExpenseMonthly) / _service.totalIncomeMonthly * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: (_service.totalIncomeMonthly -
                                _service.totalExpenseMonthly >=
                            0)
                        ? Col.greenAccent
                        : Col.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalProdukContainer() {
    return Skeletonizer(
      enabled: _service.incomeData.isEmpty && _service.expenseData.isEmpty,
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
              Text('Total Produk',
                  style: Typo.bodyTextStyle.copyWith(fontWeight: Fw.medium)),
              Text(totalProdukText,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.burger,
                        color: Col.greyColor,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(makananProdukText,
                          style: Typo.emphasizedBodyTextStyle.copyWith(
                              color: Col.greyColor,
                              fontSize: 12,
                              fontWeight: Fw.bold)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text('|',
                      style: Typo.emphasizedBodyTextStyle.copyWith(
                          color: Col.greyColor,
                          fontSize: 12,
                          fontWeight: Fw.bold)),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.mugHot,
                        color: Col.greyColor,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(minumanProdukText,
                          style: Typo.emphasizedBodyTextStyle.copyWith(
                              color: Col.greyColor,
                              fontSize: 12,
                              fontWeight: Fw.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAktivitasContainer() {
    return Skeletonizer(
      enabled: _service.incomeData.isEmpty && _service.expenseData.isEmpty,
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
              Text('Total Aktivitas',
                  style: Typo.bodyTextStyle.copyWith(fontWeight: Fw.medium)),
              Text(monthlyActivityCount.toString(),
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPengurusContainer() {
    return Skeletonizer(
      enabled: _service.incomeData.isEmpty && _service.expenseData.isEmpty,
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
              const Text('Pengurus'),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    enableDrag: true,
                    backgroundColor: Col.backgroundColor,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: ListUser(),
                      );
                    },
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: Stack(
                    children: [
                      for (int i = 0; i < userProfiles.length; i++)
                        if (i < 4)
                          Positioned(
                            left: i * 20.0,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Col.greyColor,
                                    backgroundImage:
                                        userProfiles[i]['photoUrl'].isNotEmpty
                                            ? NetworkImage(
                                                userProfiles[i]['photoUrl'])
                                            : null,
                                    child: userProfiles[i]['photoUrl'].isEmpty
                                        ? const FaIcon(
                                            FontAwesomeIcons.solidUser,
                                            size: 22,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                if (userProfiles.length > 4)
                                  Text('+${userProfiles.length - 4}'),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer() {
    return Skeletonizer(
      enabled: _service.incomeData.isEmpty && _service.expenseData.isEmpty,
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                    'Grafik',
                    style: Typo.titleTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SfCartesianChartWidget(
                incomeData: _service.incomeData,
                expenseData: _service.expenseData,
              ),
              const SizedBox(height: 8),
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
                          fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildChartExpenseContainer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
          // Text('Pengeluaran', style: Typo.titleTextStyle),
          SfDoughnutChartWidget(
            expenseData: _service.monthlyExpenseData,
          ),
        ],
      ),
    );
  }
}
