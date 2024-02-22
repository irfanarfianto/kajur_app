import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

class DetailProduk extends StatelessWidget {
  final DocumentSnapshot document;
  final String imageUrl;
  final String productName;
  // final String description;
  final VoidCallback onTapDescription;

  const DetailProduk({
    super.key,
    required this.document,
    required this.imageUrl,
    required this.productName,
    // required this.description,
    required this.onTapDescription,
  });

  @override
  Widget build(BuildContext context) {
    String documentId = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Product Image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['stok'] == 0
                          ? 'Stok Habis'
                          : 'Sisa ${data['stok'] ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            data['stok'] == 0 ? Col.redAccent : Col.greyColor,
                      ),
                    ),
                    Text(
                      data['deskripsi'],
                      style: Typo.emphasizedBodyTextStyle,
                      maxLines: 2,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Col.primaryColor,
                shape: const StadiumBorder(
                    side: BorderSide(
                  color: Col.primaryColor,
                  width: 1,
                )),
                elevation: 0,
              ),
              onPressed: onTapDescription,
              child: const Text('Detail Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
