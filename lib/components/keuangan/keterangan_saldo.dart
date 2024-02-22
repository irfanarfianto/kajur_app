import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/utils/design/system.dart';

class KeteranganSaldo extends StatelessWidget {
  const KeteranganSaldo({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Alokasi dana',
            style: Typo.titleTextStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dana Darurat:'),
              Text(
                currencyFormat.format(300000),
                style: Typo.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dana Operasional:'),
              Text(
                currencyFormat.format(200000),
                style: Typo.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'))
        ],
      ),
    );
  }
}
