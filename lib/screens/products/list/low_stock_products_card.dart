import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

class LowStockProductsCard extends StatelessWidget {
  final DocumentSnapshot document;
  final bool isLowStock;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const LowStockProductsCard({
    super.key,
    required this.document,
    required this.isLowStock,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String documentId = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return isLowStock
        ? Card(
            elevation: 0,
            color: Col.secondaryColor,
            shadowColor: Col.greyColor.withOpacity(0.10),
            child: InkWell(
              onLongPress: onLongPress,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                data['menu'],
                                style: Typo.emphasizedBodyTextStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            Text(
                              data['stok'] == 0
                                  ? 'Stok Habis'
                                  : 'Sisa ${data['stok'] ?? 0}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isLowStock ? Col.redAccent : Col.greyColor,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //   width: 30,
                        //   height: 40,
                        //   child: InkWell(
                        //     onTap: () {
                        //       showUpdateStokDialog(
                        //         context,
                        //         documentId,
                        //         data['menu'],
                        //         data['stok'],
                        //         document['image'],
                        //       );
                        //     },
                        //     child: Container(
                        //       alignment: Alignment.topCenter,
                        //       width: 30,
                        //       height: 40,
                        //       child: const Icon(
                        //         Icons.more_vert,
                        //         color: Col.greyColor,
                        //         size: 18,
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
