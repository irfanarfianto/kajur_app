import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/stok.dart';

class StockPage extends StatefulWidget {
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  Future<void> _refreshData() async {
    try {
      // ... your refresh logic
    } catch (error) {
      // Handle error if it occurs during data refresh
      print('Error refreshing data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info Stok 📢'),
        actions: [
          // Adding the IconButton for sharing
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                // Implement your sharing logic here
                // For example, you can open a share dialog
                // with the content you want to share
                // Share.share('Check out this stock information!');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshData();
        },
        child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          children: [
            StreamBuilder<QuerySnapshot>(
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
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('Belum ada info baru',
                            style: TextStyle(color: DesignSystem.blackColor)),
                      );
                    }

                    List<Widget> stockContainers = [];

                    List<Widget> outOfStockContainers = snapshot.data!.docs
                        .where((document) =>
                            (document.data() as Map<String, dynamic>)['stok'] ==
                            0)
                        .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String namaProduk = data['menu'];
                      int stok = data['stok'];
                      String documentId = document.id;

                      return buildStockContainer(
                        context,
                        namaProduk,
                        stok,
                        documentId,
                        Colors.red.withOpacity(.10),
                        Colors.red.withOpacity(.50),
                      );
                    }).toList();

                    List<Widget> criticalStockContainers = snapshot.data!.docs
                        .where((document) =>
                            (document.data() as Map<String, dynamic>)['stok'] <
                                5 &&
                            (document.data() as Map<String, dynamic>)['stok'] >
                                0)
                        .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String namaProduk = data['menu'];
                      int stok = data['stok'];
                      String documentId = document.id;

                      return buildStockContainer(
                        context,
                        namaProduk,
                        stok,
                        documentId,
                        Colors.red.withOpacity(.10),
                        Colors.red.withOpacity(.20),
                      );
                    }).toList();

                    List<Widget> lowStockContainers = snapshot.data!.docs
                        .where((document) =>
                            (document.data() as Map<String, dynamic>)['stok'] <=
                                10 &&
                            (document.data() as Map<String, dynamic>)['stok'] >
                                4)
                        .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String namaProduk = data['menu'];
                      int stok = data['stok'];
                      String documentId = document.id;

                      return buildStockContainer(
                        context,
                        namaProduk,
                        stok,
                        documentId,
                        Colors.yellow.withOpacity(.30),
                        Colors.yellow.withOpacity(.20),
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
                      return Column(
                        children: stockContainers,
                      );
                    } else {
                      return Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 3),
                          Center(
                            child: Text(
                              'Belum ada info stok',
                              style: TextStyle(color: DesignSystem.blackColor),
                            ),
                          ),
                        ],
                      );
                    }
                }
              },
            ),
          ],
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

GestureDetector buildStockContainer(
  BuildContext context,
  String namaProduk,
  int stok,
  String documentId,
  Color containerColor,
  Color borderColor,
) {
  return GestureDetector(
    onTap: () async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditStockPage(
            namaProduk: namaProduk,
            stok: stok,
            documentId: documentId,
          ),
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              getStockMessage(namaProduk, stok),
              style: TextStyle(
                color: DesignSystem.blackColor,
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
