import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

Widget buildHapusProdukWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Detail Produk',
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
          const Text('Kode Barang:', style: Typo.emphasizedBodyTextStyle),
          Text(
            '${activityData['kodeBarang'] ?? '-'}',
            style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nama:', style: Typo.emphasizedBodyTextStyle),
          Text(
            (activityData['productName'] ?? '').length > 20
                ? '${activityData['productName']?.substring(0, 20) ?? ''}...'
                : activityData['productName'] ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
          ),
        ],
      ),
      // Menampilkan informasi lain yang diperlukan
    ],
  );
}
