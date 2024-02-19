import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/widget/catergory_icon.dart';

Widget buildTransaksiKeluarWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Detail Transaksi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Col.greyColor,
            ),
          ),
          DottedDashedLine(
            height: 2,
            strokeWidth: 1,
            width: 200,
            axis: Axis.horizontal,
            dashColor: Col.greyColor.withOpacity(0.50),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Status:', style: Typo.emphasizedBodyTextStyle),
          Row(
            children: [
              const Text(
                'Selesai',
                style: TextStyle(fontSize: 14, fontWeight: Fw.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    //
                    borderRadius: BorderRadius.circular(50),
                    color: Col.greenAccent),
                child: const Icon(
                  Icons.check,
                  color: Col.whiteColor,
                  size: 12,
                ),
              )
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Keperluan:', style: Typo.emphasizedBodyTextStyle),
          Row(
            children: [
              Text(
                '${activityData['category'] ?? 'Uncategorized'}',
                style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
              ),
              CategoryIcon(
                category: activityData['category'],
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Jumlah:', style: Typo.emphasizedBodyTextStyle),
          Row(
            children: [
              Text(
                currencyFormat.format(activityData['amount']),
                style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Keterangan:', style: Typo.emphasizedBodyTextStyle),
          Text(
            '${activityData['description'] ?? 'Tidak ada'}',
            style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
          ),
        ],
      ),
    ],
  );
}
