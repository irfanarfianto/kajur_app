import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';
import 'package:kajur_app/screens/products/history.dart';
import 'package:timeago/timeago.dart' as timeago;

enum CategoryFilter {
  All,
  Makanan,
  Minuman,
}

enum SortingOption {
  Terbaru,
  AZ,
  ZA,
}

class ListProdukPage extends StatefulWidget {
  @override
  _ListProdukPageState createState() => _ListProdukPageState();
}

class _ListProdukPageState extends State<ListProdukPage> {
  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;
  CategoryFilter _categoryFilter = CategoryFilter.All;
  SortingOption _sortingOption = SortingOption.Terbaru;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
  }

  Future<void> _deleteProduct(String documentId) async {
    await _produkCollection.doc(documentId).delete();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Perform fetching or refreshing data here
    // For example, refetch Firestore data
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay

    setState(() {
      _isRefreshing = false;
    });
  }

  Widget buildCategoryButton(CategoryFilter category, String label) {
    return ElevatedButton(
      style: _categoryFilter == category
          ? ElevatedButton.styleFrom(primary: DesignSystem.purpleAccent)
          : ElevatedButton.styleFrom(
              primary: DesignSystem.greyColor.withOpacity(.20)),
      onPressed: () {
        setState(() {
          _categoryFilter = category;
        });
      },
      child: Text(label),
    );
  }

  Widget buildSortingButton(SortingOption option, String label) {
    return ElevatedButton(
      style: _sortingOption == option
          ? ElevatedButton.styleFrom(primary: DesignSystem.purpleAccent)
          : ElevatedButton.styleFrom(
              primary: DesignSystem.greyColor.withOpacity(.20)),
      onPressed: () {
        setState(() {
          _sortingOption = option;
        });
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Produk'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ActivityHistoryPage(), 
                ),
              );
            },
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCategoryButton(CategoryFilter.All, 'Semua'),
                  SizedBox(width: 8),
                  buildCategoryButton(CategoryFilter.Makanan, 'Makanan'),
                  SizedBox(width: 8),
                  buildCategoryButton(CategoryFilter.Minuman, 'Minuman'),
                  SizedBox(width: 8),
                  buildSortingButton(SortingOption.Terbaru, 'Terbaru'),
                  SizedBox(width: 8),
                  buildSortingButton(SortingOption.AZ, 'A-Z'),
                  SizedBox(width: 8),
                  buildSortingButton(SortingOption.ZA, 'Z-A'),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: StreamBuilder<QuerySnapshot>(
                stream: _produkCollection.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _isRefreshing) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Products Available',
                        style: TextStyle(color: DesignSystem.whiteColor),
                      ),
                    );
                  }

                  List<DocumentSnapshot> filteredProducts =
                      snapshot.data!.docs.where((document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    if (_categoryFilter == CategoryFilter.All) {
                      return true;
                    } else if (_categoryFilter == CategoryFilter.Makanan) {
                      return data['kategori'] == 'Makanan';
                    } else {
                      return data['kategori'] == 'Minuman';
                    }
                  }).toList();

                  filteredProducts.sort((a, b) {
                    Map<String, dynamic> dataA =
                        a.data() as Map<String, dynamic>;
                    Map<String, dynamic> dataB =
                        b.data() as Map<String, dynamic>;

                    if (_sortingOption == SortingOption.Terbaru) {
                      Timestamp timeA = dataA['updatedAt'] ?? Timestamp.now();
                      Timestamp timeB = dataB['updatedAt'] ?? Timestamp.now();
                      return timeB.compareTo(timeA);
                    } else if (_sortingOption == SortingOption.AZ) {
                      return dataA['menu'].compareTo(dataB['menu']);
                    } else {
                      return dataB['menu'].compareTo(dataA['menu']);
                    }
                  });

                  return ListView(
                    children: filteredProducts.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String documentId = document.id;

                      Timestamp updatedAt =
                          data['updatedAt'] ?? Timestamp.now();

                      return ListTile(
                        title: Text(
                          data['menu'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: DesignSystem.whiteColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Harga: ${data['harga']}',
                              style: TextStyle(
                                color: DesignSystem.whiteColor,
                              ),
                            ),
                            Text(
                              'Updated At: ${timeago.format(updatedAt.toDate(), locale: 'id')}',
                              style: TextStyle(
                                color: DesignSystem.whiteColor,
                              ),
                            ),
                          ],
                        ),
                        leading: Image.network(
                          data['image'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 200),
                              pageBuilder: (_, __, ___) =>
                                  DetailProdukPage(documentId: documentId),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
