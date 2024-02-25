import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/services/keuangan/keuangan_services.dart';
import 'package:kajur_app/utils/animation/route/slide_left.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/Tracking/tracking_page.dart';

class TotalSaldo extends StatelessWidget {
  final KeuanganService service;
  final NumberFormat currencyFormat;

  const TotalSaldo({
    super.key,
    required this.service,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Col.primaryColor.withOpacity(0.6), Col.primaryColor],
            ),
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
              const Text(
                'Total Saldo',
                style: TextStyle(fontSize: 18.0, color: Col.whiteColor),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  service.toggleShowBalance();
                },
                child: Text(
                  service.showBalance
                      ? currencyFormat.format(service.totalSaldo)
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
                '*Update ${DateFormat('dd MMMM yyyy HH:mm', 'id').format(service.saldoTimestamp)}',
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Col.whiteColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -10,
          bottom: -50,
          child: ClipRRect(
            child: Image.asset(
              'images/man2.png',
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
            right: 5,
            top: 5,
            child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideLeftRoute(page: const ChartPage()),
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.expand,
                  color: Col.whiteColor,
                  size: 20,
                ))),
      ],
    );
  }
}
