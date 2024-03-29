import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/utils/animation/route/slide_up.dart';
import 'package:kajur_app/components/activity/activity_widget.dart';
import 'package:kajur_app/components/keuangan/card_saldo.dart';
import 'package:kajur_app/components/menu%20button/menu.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/keuangan/form_pemasukan_page.dart';
import 'package:kajur_app/screens/keuangan/form_pengeluaran_page.dart';
import 'package:kajur_app/services/keuangan/keuangan_services.dart';
import 'package:skeletonizer/skeletonizer.dart';

class KeuanganContent extends StatefulWidget {
  final String userRole;
  const KeuanganContent({super.key, required this.userRole});

  @override
  State<KeuanganContent> createState() => _KeuanganContentState();
}

class _KeuanganContentState extends State<KeuanganContent> {
  final KeuanganService _service = KeuanganService();
  late String _userRole = '';

  @override
  void initState() {
    super.initState();
    _service.listenToTotalSaldo();
    _userRole = widget.userRole;
    _service.saldoTimestamp = DateTime.now();

    _service.onDataLoaded = () {
      if (mounted) {
        setState(() {});
      }
    };
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
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              alignment: Alignment.topCenter,
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
                  TotalSaldo(service: _service, currencyFormat: currencyFormat),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_userRole == 'admin' || _userRole == 'staf')
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
                            icon: const FaIcon(
                              FontAwesomeIcons.circleArrowDown,
                              size: 20,
                            ),
                            label: const Text('Catat pemasukan')),
                      if (_userRole == 'admin' || _userRole == 'staf')
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
                            icon: const FaIcon(
                              FontAwesomeIcons.circleArrowUp,
                              size: 20,
                            ),
                            label: const Text('Catat pengeluaran')),
                    ],
                  )
                ],
              ),
            ),
          ),
          buildMenuWidget(context, _userRole),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: buildRecentActivityWidget(context),
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
