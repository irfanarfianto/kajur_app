import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/stok/stok_produk.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildStockWidget(BuildContext context) {
  return Column(
    children: [
      Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: DesignSystem.secondaryColor,
            border: Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.greyColor.withOpacity(.10),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.keep(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Info Stok 📢',
                      style: DesignSystem.titleTextStyle,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const StockPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                      child: const Row(
                        children: [
                          Text(
                            "Lihat semua",
                            style: DesignSystem.bodyTextStyle,
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.east,
                            color: DesignSystem.blackColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('kantin')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              default:
                                if (snapshot.data!.docs.isEmpty) {
                                  return const Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          'Belum ada info stok',
                                          style: TextStyle(
                                              color: DesignSystem.blackColor),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                List<Widget> stockWidgets = snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String namaProduk = data['menu'];
                                  int stok = data['stok'];

                                  if (stok == 0) {
                                    return Skeleton.leaf(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(.10),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(.50),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Produk $namaProduk sudah habis!',
                                                style: const TextStyle(
                                                  color:
                                                      DesignSystem.blackColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else if (stok <= 10 && stok > 4) {
                                    return Skeleton.leaf(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.withOpacity(.30),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Colors.yellow.withOpacity(.20),
                                          ),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Pantau terus! $namaProduk sisa $stok, segera restock ya!',
                                                  style: const TextStyle(
                                                    color:
                                                        DesignSystem.blackColor,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    );
                                  } else if (stok < 5) {
                                    return Skeleton.leaf(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(.10),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(.20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Woy! $namaProduk mau abis, sisa $stok!',
                                                style: const TextStyle(
                                                  color:
                                                      DesignSystem.blackColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                }).toList();

                                return Column(
                                  children: stockWidgets,
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
