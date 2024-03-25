import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsCard extends StatefulWidget {
  final DocumentSnapshot document;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback? addCart;
  final VoidCallback? removeCart;
  final bool isInCart;
  final int quantity;

  const ProductsCard({
    super.key,
    required this.document,
    required this.onLongPress,
    required this.onTap,
    required this.addCart,
    required this.removeCart,
    required this.isInCart,
    required this.quantity,
  });

  @override
  _ProductsCardState createState() => _ProductsCardState();
}

class _ProductsCardState extends State<ProductsCard> {
  @override
  Widget build(BuildContext context) {
    String documentId = widget.document.id;
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.only(top: 16),
        elevation: 0,
        color: Col.secondaryColor,
        shadowColor: Col.greyColor.withOpacity(0.10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                      width: double.infinity,
                      height: 170,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Col.whiteColor,
                      border: Border.all(color: Col.primaryColor, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.isInCart)
                          InkWell(
                            onTap: widget.removeCart,
                            child: const Icon(
                              Icons.remove,
                              color: Col.primaryColor,
                              size: 15,
                            ),
                          ),
                        if (widget.isInCart)
                          SizedBox(
                              width: 30,
                              height: 15,
                              child: Text(
                                '${widget.quantity}',
                                textAlign: TextAlign.center,
                                style: Typo.bodyTextStyle.copyWith(
                                  color: Col.greyColor,
                                  fontWeight: Fw.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                        InkWell(
                          onTap: widget.addCart,
                          child: Icon(
                            widget.isInCart
                                ? Icons.add
                                : Icons.add_shopping_cart,
                            color: Col.primaryColor,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data['menu'],
              textAlign: TextAlign.start,
              maxLines: 2,
              style: Typo.titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              data['stok'] == 0
                  ? 'Stok sudah habis'
                  : 'Sisa stok ${data['stok'] ?? 0}',
              style: TextStyle(
                fontSize: 14,
                color: data['stok'] == 0 ? Col.redAccent : Col.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
