import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/produk/update_stock_dialog.dart';
import 'package:kajur_app/utils/design/system.dart';

class HighStockProductsCard extends StatelessWidget {
  final DocumentSnapshot document;
  final bool isHighStock;
  final VoidCallback onTap;

  const HighStockProductsCard({
    super.key,
    required this.document,
    required this.isHighStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String documentId = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return isHighStock
        ? Card(
            elevation: 0,
            color: Col.secondaryColor,
            shadowColor: Col.greyColor.withOpacity(0.10),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product_image_$documentId',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          imageUrl: data['image'],
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Col.greyColor.withOpacity(0.10),
                            child: Icon(
                              Icons.hide_image_rounded,
                              color: Col.greyColor.withOpacity(0.50),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            color: Col.greyColor.withOpacity(0.10),
                            child: Icon(
                              Icons.image,
                              color: Col.greyColor.withOpacity(0.50),
                            ),
                          ),
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['menu'],
                            style: Typo.emphasizedBodyTextStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            data['stok'] == 0
                                ? 'Stok sudah habis'
                                : 'Sisa stok ${data['stok'] ?? 0}',
                            style: TextStyle(
                              fontSize: 14,
                              color: data['stok'] == 0
                                  ? Col.redAccent
                                  : Col.greyColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '*Diperbarui ${DateFormat('dd MMM y HH:mm', 'id_ID').format(data['updatedAt']?.toDate() ?? DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Col.greyColor,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 100,
                      child: InkWell(
                        onTap: () {
                          showUpdateStokDialog(
                            context,
                            documentId,
                            data['menu'],
                            data['stok'],
                            document['image'],
                          );
                        },
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: 60,
                          height: 100,
                          child: const Icon(
                            Icons.more_vert,
                            color: Col.greyColor,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : const SizedBox(); // Skip if low stock
  }
}
