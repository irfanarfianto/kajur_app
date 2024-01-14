import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  bool _enabled = false;

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
      _enabled = false; // Enable skeleton loading while data is being refreshed
    });

    try {
      // Turn off refreshing state after completion
      setState(() {
        _isRefreshing = false;
        _enabled = true;
      });

      // Fetch or refresh data here (e.g., refetch Firestore data)
      await Future.delayed(Duration(seconds: 2)); // Simulating a delay
    } catch (error) {
      // Handle error in case of any issues during refresh
      print('Error refreshing data: $error');
    } finally {
      // Disable skeleton loading after data has been fetched or in case of an error
      setState(() {
        _enabled = false;
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
              ))
          : ElevatedButton.styleFrom(
              primary: DesignSystem.backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
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
                      color: DesignSystem.blackColor,
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
                          borderSide: BorderSide.none),
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
                Navigator.pushNamed(context, '/comingsoon');
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
          SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: DesignSystem.backgroundColor,
              onRefresh: _refreshData,
              child: Skeletonizer(
                enabled: _enabled,
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
                      return Skeletonizer(
                        enabled: _enabled,
                        child:
                            Container(), // Add the required 'child' argument here
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
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing:
                              20.0, // Adjusted the main axis spacing
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = filteredProducts[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String documentId = document.id;

                          Timestamp updatedAt =
                              data['updatedAt'] ?? Timestamp.now();

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      Duration(milliseconds: 200),
                                  pageBuilder: (_, __, ___) => DetailProdukPage(
                                    documentId: documentId,
                                  ),
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
                            child: Card(
                              elevation: 0,
                              color: DesignSystem.backgroundColor,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: DesignSystem.greyColor
                                                  .withOpacity(.10),
                                              offset: Offset(0, 5),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            data['image'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['menu'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: DesignSystem.blackColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Skeleton.unite(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: data['stok'] == 0
                                              ? DesignSystem.redAccent
                                                  .withOpacity(.80)
                                              : data['stok'] < 5
                                                  ? DesignSystem.primaryColor
                                                      .withOpacity(.80)
                                                  : DesignSystem.primaryColor
                                                      .withOpacity(.80),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          data['stok'] == 0
                                              ? 'Stok habis'
                                              : '${data['stok'] ?? 0}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: DesignSystem.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
