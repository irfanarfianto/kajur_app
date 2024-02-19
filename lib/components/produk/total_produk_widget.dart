import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/utils/animation/route/slide_left.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/products/list/list_products_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildTotalProductsWidget(BuildContext context) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('kantin').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Skeleton.keep(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(left: 16),
                          height: 150,
                          width: 160,
                        ),
                      ),
                    ),
                  ),
                );
              default:
                int totalProducts = snapshot.data!.size;
                int totalFoodProducts = snapshot.data!.docs
                    .where((doc) => doc['kategori'] == 'Makanan')
                    .toList()
                    .length;
                int totalDrinkProducts = snapshot.data!.docs
                    .where((doc) => doc['kategori'] == 'Minuman')
                    .toList()
                    .length;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Widget pertama
                      Skeleton.keep(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              height: 150,
                              width: 160,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Col.primaryColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Col.whiteColor.withOpacity(.20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Total Produk',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Col.whiteColor,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.all(0),
                                        tooltip: 'Lihat semua produk',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              SlideLeftRoute(
                                                  page:
                                                      const ListProdukPage()));
                                        },
                                        icon: const Icon(
                                          Icons.east,
                                          color: Col.whiteColor,
                                        ),
                                        iconSize: 15,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$totalProducts',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Col.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -5,
                              right: -30,
                              child: ClipRect(
                                child: ClipPath(
                                  clipper: MyClipper(),
                                  child: Image.asset(
                                    'images/List.png',
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),
                      Skeleton.keep(
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: 160,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Col.orangeAccent,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Col.whiteColor.withOpacity(.20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Makanan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Col.whiteColor,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.all(0),
                                        tooltip: 'Lihat semua produk',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              SlideLeftRoute(
                                                  page:
                                                      const ListProdukPage()));
                                        },
                                        icon: const Icon(
                                          Icons.east,
                                          color: Col.whiteColor,
                                        ),
                                        iconSize: 15,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$totalFoodProducts',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Col.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              right: -30,
                              child: ClipRect(
                                child: ClipPath(
                                  clipper: MyClipper(),
                                  child: Image.asset(
                                    'images/Food.png',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Skeleton.keep(
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              width: 160,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Col.purpleAccent,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Col.whiteColor.withOpacity(.20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Minuman',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Col.whiteColor,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.all(0),
                                        tooltip: 'Lihat semua produk',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              SlideLeftRoute(
                                                  page:
                                                      const ListProdukPage()));
                                        },
                                        icon: const Icon(
                                          Icons.east,
                                          color: Col.whiteColor,
                                        ),
                                        iconSize: 15,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$totalDrinkProducts',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      color: Col.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              right: -30,
                              child: ClipRect(
                                child: ClipPath(
                                  clipper: MyClipper(),
                                  child: Image.asset(
                                    'images/Coffee.png',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      )
                    ],
                  ),
                );
            }
          },
        ),
      ],
    ),
  );
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Atur bentuk clipping mask sesuai keinginan Anda
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(
        0, size.height * 0.8); // Ubah sesuai dengan bentuk yang diinginkan
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
