import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildTotalProductsWidget(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Center(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: DesignSystem.primaryColor,
          border: Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
          boxShadow: [
            BoxShadow(
              color: DesignSystem.greyColor.withOpacity(.10),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kantin')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total Produk $totalProducts',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: DesignSystem.regular,
                                      color: DesignSystem.whiteColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: DesignSystem.whiteColor
                                                    .withOpacity(.20),
                                              )),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Skeleton.leaf(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.restaurant,
                                                      color: DesignSystem
                                                          .whiteColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '$totalFoodProducts',
                                                      style: const TextStyle(
                                                        fontSize: 25,
                                                        color: DesignSystem
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Skeleton.keep(
                                                child: Text(
                                                  'Makanan',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        DesignSystem.whiteColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: DesignSystem.whiteColor
                                                    .withOpacity(.20),
                                              )),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Skeleton.leaf(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.local_cafe_outlined,
                                                      color: DesignSystem
                                                          .whiteColor,
                                                      size: 25,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '$totalDrinkProducts',
                                                      style: const TextStyle(
                                                        fontSize: 25,
                                                        color: DesignSystem
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Skeleton.keep(
                                                child: Text(
                                                  'Minuman',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color:
                                                        DesignSystem.whiteColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                      }
                    })
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ListProdukPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );

                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Skeleton.keep(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: DesignSystem.whiteColor.withOpacity(.20),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Lihat semua",
                          style: TextStyle(
                            color: DesignSystem.whiteColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.east,
                          color: DesignSystem.whiteColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
