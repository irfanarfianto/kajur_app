import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Col.primaryColor,
        foregroundColor: Col.whiteColor,
        surfaceTintColor: Col.primaryColor,
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
        backgroundColor: Col.backgroundColor,
        color: Col.primaryColor,
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
                          style: TextStyle(color: Col.blackColor),
                        ),
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

                      int stok = data['stok'];

                      return Skeleton.leaf(
                        child: Container(
                          width: 120,
                          height: 120,
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
                                        colors: stok == 0
                                            ? [
                                                Col.redAccent
                                                    .withOpacity(.75),
                                                Col.redAccent
                                              ]
                                            : [
                                                Col.primaryColor
                                                    .withOpacity(.75),
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
                                        stok == 0
                                            ? 'Stok habis'
                                            : 'Sisa stok $stok',
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

                      int stok = data['stok'];

                      return Skeleton.leaf(
                        child: Container(
                          width: 120,
                          height: 120,
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
                                        colors: stok == 0
                                            ? [
                                                Col.redAccent
                                                    .withOpacity(.75),
                                                Col.redAccent
                                              ]
                                            : [
                                                Col.primaryColor
                                                    .withOpacity(.75),
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
                                        stok == 0
                                            ? 'Stok habis'
                                            : 'Sisa stok $stok',
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

                      int stok = data['stok'];

                      return Skeleton.leaf(
                        child: Container(
                          width: 120,
                          height: 120,
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
                                        colors: stok == 0
                                            ? [
                                                Col.redAccent
                                                    .withOpacity(.75),
                                                Col.redAccent
                                              ]
                                            : [
                                                Col.primaryColor
                                                    .withOpacity(.75),
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
                                        stok == 0
                                            ? 'Stok habis'
                                            : 'Sisa stok $stok',
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
                      return GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        children: stockContainers,
                      );
                    } else {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            child: const Center(
                              child: Text(
                                'Belum ada info stok',
                                style:
                                    TextStyle(color: Col.blackColor),
                              ),
                            ),
                          );
                        },
                      );
                    }
                }
              },
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
}
