import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsCard extends StatefulWidget {
  final DocumentSnapshot document;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback addCart;

  const ProductsCard({
    super.key,
    required this.document,
    required this.onLongPress,
    required this.onTap,
    required this.addCart,
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
                  bottom: 5,
                  right: 5,
                  child: IconButton(
                    padding: const EdgeInsets.all(5),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Col.primaryColor),
                    ),
                    onPressed: widget.addCart,
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Col.whiteColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              textAlign: TextAlign.start,
              maxLines: 2,
              data['menu'],
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
