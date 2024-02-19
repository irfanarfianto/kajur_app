import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/products/details/details_products_page.dart';

Widget buildTambahProdukWidget(
    BuildContext context, Map<String, dynamic> activityData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
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
      const SizedBox(
        height: 25,
      ),
      // Tombol Detail Produk
      TextButton(
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
            // Tampilkan showBottomSheet setengah layar jika ID produk tidak tersedia
            _showHalfScreenBottomSheet(context);
          }
        },
        child: const Text(
          'Detail Produk',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

void _showHalfScreenBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(
          child: Text(
            'Informasi Produk tidak tersedia.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    },
  );
}
