import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/stok/update_stok.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) {
      return; // Check if the widget is still mounted
    }

    // Set state to indicate refreshing
    setState(() {
      _enabled = true;
    });

    try {
      // Fetch or refresh data here (e.g., refetch Firestore data)
      await Future.delayed(const Duration(seconds: 1)); // Simulating a delay
    } catch (error) {
      // Handle error in case of any issues during refresh
    } finally {
      // Disable skeleton loading after data has been fetched or in case of an error
      if (mounted) {
        // Check again before calling setState
        setState(() {
          _enabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: const Center(child: Text('Info Stok 📢')),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Navigator.pushNamed(context, '/comingsoon');
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          backgroundColor: DesignSystem.backgroundColor,
          color: DesignSystem.primaryColor,
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Skeletonizer(
              enabled: _enabled,
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
                            'Belum ada info baru',
                            style: TextStyle(color: DesignSystem.blackColor),
                          ),
                        );
                      }

                      List<Widget> stockContainers = [];

                      List<Widget> outOfStockContainers = snapshot.data!.docs
                          .where((document) =>
                              (document.data()
                                  as Map<String, dynamic>)['stok'] ==
                              0)
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String namaProduk = data['menu'];
                        int stok = data['stok'];
                        String documentId = document.id;
                        Timestamp updatedAt =
                            data['updatedAt'] ?? Timestamp.now();

                        return buildStockContainer(
                          context,
                          namaProduk,
                          stok,
                          documentId,
                          Colors.red.withOpacity(.10),
                          Colors.red.withOpacity(.50),
                          updatedAt,
                        );
                      }).toList();

                      List<Widget> criticalStockContainers = snapshot.data!.docs
                          .where((document) =>
                              (document.data()
                                      as Map<String, dynamic>)['stok'] <
                                  5 &&
                              (document.data()
                                      as Map<String, dynamic>)['stok'] >
                                  0)
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String namaProduk = data['menu'];
                        int stok = data['stok'];
                        String documentId = document.id;
                        Timestamp updatedAt =
                            data['updatedAt'] ?? Timestamp.now();

                        return buildStockContainer(
                          context,
                          namaProduk,
                          stok,
                          documentId,
                          Colors.red.withOpacity(.10),
                          Colors.red.withOpacity(.20),
                          updatedAt,
                        );
                      }).toList();

                      List<Widget> lowStockContainers = snapshot.data!.docs
                          .where((document) =>
                              (document.data()
                                      as Map<String, dynamic>)['stok'] <=
                                  10 &&
                              (document.data()
                                      as Map<String, dynamic>)['stok'] >
                                  4)
                          .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String namaProduk = data['menu'];
                        int stok = data['stok'];
                        String documentId = document.id;
                        Timestamp updatedAt =
                            data['updatedAt'] ?? Timestamp.now();

                        return buildStockContainer(
                          context,
                          namaProduk,
                          stok,
                          documentId,
                          Colors.yellow.withOpacity(.30),
                          Colors.yellow.withOpacity(.20),
                          updatedAt,
                        );
                      }).toList();

                      // Add the containers to the main list in the desired order
                      if (outOfStockContainers.isNotEmpty) {
                        stockContainers
                            .add(buildCategoryTitle('Stok sudah habis'));
                        stockContainers.addAll(outOfStockContainers);
                      }

                      if (criticalStockContainers.isNotEmpty) {
                        stockContainers
                            .add(buildCategoryTitle('Stok kurang dari 5'));
                        stockContainers.addAll(criticalStockContainers);
                      }

                      if (lowStockContainers.isNotEmpty) {
                        stockContainers
                            .add(buildCategoryTitle('Stok kurang dari 10'));
                        stockContainers.addAll(lowStockContainers);
                      }

                      if (stockContainers.isNotEmpty) {
                        return ListView(
                          children: stockContainers,
                        );
                      } else {
                        return ListView(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height / 3),
                            const Center(
                              child: Text(
                                'Belum ada info stok',
                                style:
                                    TextStyle(color: DesignSystem.blackColor),
                              ),
                            ),
                          ],
                        );
                      }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildStockContainer(
    BuildContext context,
    String namaProduk,
    int stok,
    String documentId,
    Color containerColor,
    Color borderColor,
    Timestamp updatedAt,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EditStockPage(
              namaProduk: namaProduk,
              stok: stok,
              documentId: documentId,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;

              var tween = Tween(begin: begin, end: end);

              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Skeleton.leaf(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  getStockMessage(namaProduk, stok),
                  style: const TextStyle(
                    color: DesignSystem.blackColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                timeago.format(updatedAt.toDate(), locale: 'id'),
                style: const TextStyle(
                  color: DesignSystem.blackColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getStockMessage(String namaProduk, int stok) {
    if (stok == 0) {
      return 'Produk $namaProduk sudah habis!';
    } else if (stok <= 10 && stok > 4) {
      return 'Pantau terus! $namaProduk sisa $stok, segera restock ya!';
    } else if (stok < 5) {
      return 'Woy! $namaProduk mau abis, sisa $stok!';
    } else {
      return ''; // Jika stok tidak rendah atau sedang, kembalikan string kosong
    }
  }
}
