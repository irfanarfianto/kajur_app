import 'dart:ui';

import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:readmore/readmore.dart';

Widget buildEditProdukWidget(
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                (activityData['newProductData']['menu'] ?? '').length > 20
                    ? '${activityData['newProductData']['menu']?.substring(0, 20) ?? ''}...'
                    : activityData['newProductData']['menu'] ?? '',
                style: Typo.emphasizedBodyTextStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga Jual', style: Typo.emphasizedBodyTextStyle),
              Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(activityData['newProductData']['hargaJual'] ?? 0),
                  style: Typo.emphasizedBodyTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gambar ', style: Typo.emphasizedBodyTextStyle),
              GestureDetector(
                onTap: () {
                  _showImageDialog(
                      context, activityData['newProductData']['image'] ?? '');
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: Col.primaryColor,
                      size: 18,
                    ),
                    Text('Lihat gambar',
                        style: TextStyle(
                          color: Col.primaryColor,
                          fontWeight: Fw.regular,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Deskripsi', style: Typo.emphasizedBodyTextStyle),
          ReadMoreText(
            '${activityData['newProductData']['deskripsi'] ?? ''}',
            trimLines: 3,
            style: Typo.emphasizedBodyTextStyle,
            colorClickableText: Col.primaryColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Baca selengkapnya',
            trimExpandedText: ' Tutup',
            moreStyle: const TextStyle(
              fontSize: 14,
              color: Col.greyColor,
              fontWeight: Fw.regular,
            ),
            lessStyle: const TextStyle(
              fontSize: 14,
              color: Col.greyColor,
              fontWeight: Fw.regular,
            ),
          ),
        ],
      ),
      // Sebelumnya
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              Text('${activityData['oldProductData']['menu'] ?? ''}',
                  style: Typo.emphasizedBodyTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga Jual', style: Typo.emphasizedBodyTextStyle),
              Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(activityData['oldProductData']['hargaJual'] ?? 0),
                  style: Typo.emphasizedBodyTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gambar ', style: Typo.emphasizedBodyTextStyle),
              GestureDetector(
                onTap: () {
                  _showImageDialog(
                      context, activityData['oldProductData']['image'] ?? '');
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: Col.primaryColor,
                      size: 18,
                    ),
                    Text('Lihat gambar',
                        style: TextStyle(
                          color: Col.primaryColor,
                          fontWeight: Fw.regular,
                        )),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kategori', style: Typo.emphasizedBodyTextStyle),
              Text('${activityData['oldProductData']['kategori'] ?? ''}',
                  style: Typo.emphasizedBodyTextStyle),
            ],
          ),
        ],
      ),

      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Deskripsi', style: Typo.emphasizedBodyTextStyle),
          ReadMoreText(
            '${activityData['oldProductData']['deskripsi'] ?? ''}',
            trimLines: 3,
            style: Typo.emphasizedBodyTextStyle,
            colorClickableText: Col.primaryColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Baca selengkapnya',
            trimExpandedText: ' Tutup',
            moreStyle: const TextStyle(
              fontSize: 14,
              color: Col.greyColor,
              fontWeight: Fw.regular,
            ),
            lessStyle: const TextStyle(
              fontSize: 14,
              color: Col.greyColor,
              fontWeight: Fw.regular,
            ),
          ),
        ],
      ),
      // Menampilkan informasi lain yang diperlukan
    ],
  );
}

void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 400,
            width: 400,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    },
  );
}
