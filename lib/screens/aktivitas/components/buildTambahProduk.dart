import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';

Widget buildTambahProdukWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Bagian Detail Produk
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
            'Detail Produk',
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
      // Informasi Produk
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
      const SizedBox(
        height: 25,
      ),
      // Tombol Detail Produk
      TextButton.icon(
        onPressed: () {
          if (activityData['productId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailProdukPage(
                  documentId: activityData['productId'],
                ),
              ),
            );
          } else {
            // Tindakan ketika ID produk tidak tersedia
          }
        },
        icon: const Icon(Icons.arrow_forward),
        label: const Text(
          'Detail Produk',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}
