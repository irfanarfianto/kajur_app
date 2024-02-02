import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/stok/stok_produk.dart';
import 'package:kajur_app/screens/widget/icon_text_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildStockWidget(BuildContext context) {
  return Column(
    children: [
      Center(
        // child: Container(
        // padding: const EdgeInsets.all(16.0),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(15),
        //   color: Col.secondaryColor,
        //   border: Border.all(color: Col.greyColor.withOpacity(.10)),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Col.greyColor.withOpacity(.10),
        //       offset: const Offset(0, 5),
        //       blurRadius: 10,
        //     ),
        //   ],
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton.keep(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Info Stok 📢',
                    style: Typo.titleTextStyle,
                  ),
                  IconTextButton(
                    text: 'Lihat semua',
                    iconData: Icons.east,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const StockPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    iconOnRight: true,
                    iconColor: Col.greyColor,
                    textColor: Col.greyColor,
                    iconSize: 15.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 130,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('kantin').snapshots(),
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
                        return const Center(
                          child: Text(
                            'Belum ada produk',
                            style: TextStyle(
                              color: Col.blackColor,
                            ),
                          ),
                        );
                      }

                      List<Widget> stockWidgets =
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        int stok = data['stok'];

                        if (stok == 0) {
                          return Skeleton.leaf(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(
                                      data['image'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Col.redAccent.withOpacity(.75),
                                              Col.redAccent
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            data['stok'] == 0
                                                ? 'Stok habis'
                                                : 'Sisa stok ${data['stok'] ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Col.whiteColor,
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
                        } else if (stok <= 10 && stok > 4) {
                          return Skeleton.leaf(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(
                                      data['image'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Col.primaryColor.withOpacity(.75),
                                              Col.primaryColor
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Sisa ${data['stok'] ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Col.whiteColor,
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
                        } else if (stok < 5) {
                          return Skeleton.leaf(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(
                                      data['image'],
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Col.primaryColor.withOpacity(.75),
                                              Col.primaryColor
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Sisa ${data['stok'] ?? 0}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Col.whiteColor,
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

                        return const SizedBox.shrink();
                      }).toList();

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: stockWidgets.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              stockWidgets[index],
                              const SizedBox(width: 8),
                            ],
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
