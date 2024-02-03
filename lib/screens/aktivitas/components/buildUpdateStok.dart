import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

Widget buildUpdateStokWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DottedDashedLine(
              height: 1,
              strokeWidth: 1,
              width: 100,
              axis: Axis.horizontal,
              dashColor: Col.greyColor.withOpacity(0.20),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Sesudah',
            style: TextStyle(
              fontSize: 12,
              fontWeight: Fw.medium,
              color: Col.greyColor,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: DottedDashedLine(
              height: 1,
              strokeWidth: 1,
              width: 100,
              axis: Axis.horizontal,
              dashColor: Col.greyColor.withOpacity(0.20),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ID Produk ', style: Typo.emphasizedBodyTextStyle),
          Text(
            (activityData['productId'] ?? '').length > 20
                ? '${activityData['productId']?.substring(0, 20) ?? ''}...'
                : activityData['productId'] ?? '-',
            style: Typo.emphasizedBodyTextStyle,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nama ', style: Typo.emphasizedBodyTextStyle),
          Text(
            (activityData['productName'] ?? '').length > 20
                ? '${activityData['productName']?.substring(0, 20) ?? ''}...'
                : activityData['productName'] ?? '',
            style: Typo.emphasizedBodyTextStyle,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Stok ', style: Typo.emphasizedBodyTextStyle),
          Text(
            ' ${activityData['newProductData']['stok'] ?? ''}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
      // Menampilkan informasi lain yang diperlukan
      const SizedBox(height: 25),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DottedDashedLine(
              height: 1,
              strokeWidth: 1,
              width: 100,
              axis: Axis.horizontal,
              dashColor: Col.greyColor.withOpacity(0.20),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'Sebelumnya',
            style: TextStyle(
              fontSize: 12,
              fontWeight: Fw.medium,
              color: Col.greyColor,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: DottedDashedLine(
              height: 1,
              strokeWidth: 1,
              width: 100,
              axis: Axis.horizontal,
              dashColor: Col.greyColor.withOpacity(0.20),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ID Produk ', style: Typo.emphasizedBodyTextStyle),
          Text(
            (activityData['productId'] ?? '').length > 20
                ? '${activityData['productId']?.substring(0, 20) ?? ''}...'
                : activityData['productId'] ?? '-',
            style: Typo.emphasizedBodyTextStyle,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Nama ', style: Typo.emphasizedBodyTextStyle),
          Text(
            (activityData['oldProductData']['menu'] ?? '').length > 20
                ? '${activityData['oldProductData']['menu']?.substring(0, 20) ?? ''}...'
                : activityData['oldProductData']['menu'] ?? '',
            style: Typo.emphasizedBodyTextStyle,
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Stok ', style: Typo.emphasizedBodyTextStyle),
          Text(
            ' ${activityData['oldProductData']['stok'] ?? ''}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
      // Menampilkan informasi lain yang diperlukan
    ],
  );
}
