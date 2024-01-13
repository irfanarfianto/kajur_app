import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:kajur_app/screens/products/details_products.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart';

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
  String _searchQuery = '';
  late AsyncSnapshot<QuerySnapshot> _currentSnapshot;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
  }

  void _resetCategoryFilter() {
    setState(() {
      _categoryFilter = CategoryFilter.All;
    });
  }

  void _resetSortingOption() {
    setState(() {
      _sortingOption = SortingOption.Terbaru;
    });
  }

  void _updateSnapshot(AsyncSnapshot<QuerySnapshot> newSnapshot) {
    setState(() {
      _currentSnapshot = newSnapshot;
    });
  }

  Future<void> _deleteProduct(String documentId) async {
    await _produkCollection.doc(documentId).delete();
  }

  Future<void> _refreshData() async {
    // Set state to indicate refreshing
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Fetch or refresh data here (e.g., refetch Firestore data)
      await Future.delayed(Duration(seconds: 2)); // Simulating a delay

      // Turn off refreshing state after completion
      setState(() {
        _isRefreshing = false;
      });
    } catch (error) {
      // Handle error in case of any issues during refresh
      print('Error refreshing data: $error');
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Widget buildCategoryButton(
      CategoryFilter category, String label, IconData icon) {
    return ElevatedButton(
      style: _categoryFilter == category
          ? ElevatedButton.styleFrom(
              primary: DesignSystem.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ))
          : ElevatedButton.styleFrom(
              primary: DesignSystem.backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              side: BorderSide(color: DesignSystem.greyColor.withOpacity(.50)),
              elevation: 0,
              onPrimary: DesignSystem.greyColor),
      onPressed: () {
        if (_categoryFilter == category) {
          _resetCategoryFilter();
        } else {
          setState(() {
            _categoryFilter = category;
          });
        }
      },
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  Widget buildSortingButton(SortingOption option, String label, IconData icon) {
    return ElevatedButton(
      style: _sortingOption == option
          ? ElevatedButton.styleFrom(
              primary: DesignSystem.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: DesignSystem.primaryColor),
              ))
          : ElevatedButton.styleFrom(
              primary: DesignSystem.backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              side: BorderSide(color: DesignSystem.greyColor.withOpacity(.50)),
              elevation: 0,
              onPrimary: DesignSystem.greyColor),
      onPressed: () {
        setState(() {
          if (_sortingOption == option) {
            _sortingOption = SortingOption.Terbaru;
          } else {
            _sortingOption = option;
          }
        });
      },
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 40,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: DesignSystem.greyColor.withOpacity(0.1),
                      contentPadding: EdgeInsets.all(8.0),
                      hintText: 'Cari produk',
                      hintStyle: TextStyle(
                        color: DesignSystem.greyColor,
                        fontSize: 14.0,
                      ),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  Visibility(
                    visible: _searchQuery != null && _searchQuery.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.clear,
                          color: DesignSystem.greyColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityHistoryPage(),
                  ),
                );
              },
              icon: Icon(Icons.history),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  buildCategoryButton(
                      CategoryFilter.All, 'Semua', Icons.category),
                  SizedBox(width: 8),
                  buildCategoryButton(
                    CategoryFilter.Makanan,
                    'Makanan',
                    Icons.restaurant,
                  ),
                  SizedBox(width: 8),
                  buildCategoryButton(
                      CategoryFilter.Minuman, 'Minuman', Icons.local_drink),
                  SizedBox(width: 8),
                  buildSortingButton(
                      SortingOption.Terbaru, 'Terbaru', Icons.access_time),
                  SizedBox(width: 8),
                  buildSortingButton(
                      SortingOption.AZ, 'A-Z', Icons.sort_by_alpha),
                  SizedBox(width: 8),
                  buildSortingButton(
                      SortingOption.ZA, 'Z-A', Icons.sort_by_alpha_outlined),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: DesignSystem.backgroundColor,
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
                    return Center();
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

                    final menuName = data['menu'].toString().toLowerCase();
                    final productCategory = data['kategori']
                        .toString()
                        .toLowerCase(); // Ganti dengan field yang sesuai di Firestore

                    return (_categoryFilter == CategoryFilter.All ||
                            (_categoryFilter == CategoryFilter.Makanan &&
                                productCategory == 'makanan') ||
                            (_categoryFilter == CategoryFilter.Minuman &&
                                productCategory == 'minuman')) &&
                        (menuName.contains(_searchQuery));
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

                  return Scrollbar(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      physics: BouncingScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot document = filteredProducts[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String documentId = document.id;

                        Timestamp updatedAt =
                            data['updatedAt'] ?? Timestamp.now();

                        return Stack(
                          children: [
                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration:
                                          Duration(milliseconds: 200),
                                      pageBuilder: (_, __, ___) =>
                                          DetailProdukPage(
                                              documentId: documentId),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
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
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data['image'],
                                          height: 80,
                                          width: 80,
                                          fit: BoxFit
                                              .cover, // Sesuaikan dengan preferensi tampilan
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Memberi jarak antara gambar dan teks
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       padding: EdgeInsets.symmetric(
                                            //           vertical: 3,
                                            //           horizontal: 12),
                                            //       decoration: BoxDecoration(
                                            //         color: data['kategori'] ==
                                            //                 'Makanan'
                                            //             ? Colors.green
                                            //                 .withOpacity(.50)
                                            //             : data['kategori'] ==
                                            //                     'Minuman'
                                            //                 ? DesignSystem
                                            //                     .primaryColor
                                            //                     .withOpacity(.50)
                                            //                 : Colors.grey,
                                            //         borderRadius:
                                            //             BorderRadius.circular(50),
                                            //       ),
                                            //       child: Text(
                                            //         data['kategori'] == 'Makanan'
                                            //             ? 'Makanan'
                                            //             : data['kategori'] ==
                                            //                     'Minuman'
                                            //                 ? 'Minuman'
                                            //                 : 'Kategori Tidak Diketahui',
                                            //         style: TextStyle(
                                            //           fontSize: 10,
                                            //           color:
                                            //               DesignSystem.whiteColor,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     SizedBox(width: 8),
                                            //     Container(
                                            //       padding: EdgeInsets.symmetric(
                                            //           vertical: 3,
                                            //           horizontal: 12),
                                            //       decoration: BoxDecoration(
                                            //         color: data['stok'] == 0
                                            //             ? DesignSystem.redAccent
                                            //                 .withOpacity(.50)
                                            //             : data['stok'] < 5
                                            //                 ? DesignSystem
                                            //                     .purpleAccent
                                            //                     .withOpacity(.50)
                                            //                 : DesignSystem
                                            //                     .purpleAccent
                                            //                     .withOpacity(.50),
                                            //         borderRadius:
                                            //             BorderRadius.circular(50),
                                            //       ),
                                            //       child: Text(
                                            //         data['stok'] == 0
                                            //             ? 'Stok habis'
                                            //             : 'Stok ${data['stok'] ?? 0}',
                                            //         style: TextStyle(
                                            //           fontSize: 10,
                                            //           color:
                                            //               DesignSystem.whiteColor,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            // SizedBox(height: 4),
                                            Text(
                                              data['menu'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: DesignSystem.blackColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            Text(
                                              'Diperbarui ${timeago.format(updatedAt.toDate(), locale: 'id')}',
                                              style: TextStyle(
                                                color: DesignSystem.blackColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
