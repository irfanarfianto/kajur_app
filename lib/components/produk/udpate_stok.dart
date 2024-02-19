import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

Widget buildUpdateStokWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sesudah',
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
          const Text('ID Produk:', style: Typo.emphasizedBodyTextStyle),
          Text(
            '${activityData['productId'] ?? '-'}',
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
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Stok baru:', style: Typo.emphasizedBodyTextStyle),
          Text(
            '${activityData['newProductData']['stok'] ?? '-'}',
            style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sebelumnya',
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ID Produk:', style: Typo.emphasizedBodyTextStyle),
              Text(
                '${activityData['productId'] ?? '-'}',
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stok lama:', style: Typo.emphasizedBodyTextStyle),
              Text(
                '${activityData['oldProductData']['stok'] ?? '-'}',
                style: const TextStyle(fontSize: 14, fontWeight: Fw.bold),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
