import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/services/auth/keuangan/keuangan_services.dart';

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
    return Container(
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
                style: TextStyle(fontSize: 18.0, color: Col.whiteColor),
              ),
              Icon(Icons.copy_outlined, color: Col.whiteColor)
            ],
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
          const Text(
            'Pendapatan bulan ini',
            style: TextStyle(
              fontSize: 14.0,
              color: Col.whiteColor,
            ),
          ),
          Text(
            currencyFormat.format(
                service.totalIncomeMonthly - service.totalExpenseMonthly),
            style: const TextStyle(
              color: Col.whiteColor,
              fontSize: 16,
              fontWeight: Fw.bold,
            ),
          ),
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
    );
  }
}
