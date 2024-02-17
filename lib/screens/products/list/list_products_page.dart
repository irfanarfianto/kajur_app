import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/components/produk/kirim_data_produk.dart';
import 'package:kajur_app/screens/products/details/details_products_page.dart';
import 'package:kajur_app/components/produk/sorting_overlay.dart';
import 'package:kajur_app/screens/products/list/high_stock_products_card.dart';
import 'package:kajur_app/screens/products/list/low_stock_products_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum CategoryFilter {
  Semua,
  Makanan,
  Minuman,
}

class ListProdukPage extends StatefulWidget {
  const ListProdukPage({super.key});

  @override
  _ListProdukPageState createState() => _ListProdukPageState();
}

class _ListProdukPageState extends State<ListProdukPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;
  final CategoryFilter _categoryFilter = CategoryFilter.Semua;
  String _searchQuery = '';
  String _sortingCriteria = 'terbaru';

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
    } catch (error) {
      print('Error refreshing data: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  CategoryFilter _getCategoryFromIndex(int index) {
    if (index == 0) {
      return CategoryFilter.Semua;
    } else if (index == 1) {
      return CategoryFilter.Makanan;
    } else {
      return CategoryFilter.Minuman;
    }
  }

  List<DocumentSnapshot> _filterProducts(QuerySnapshot snapshot) {
    return snapshot.docs.where((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final menuName = data['menu'].toString().toLowerCase();
      final productCategory = data['kategori'].toString().toLowerCase();

      return (_categoryFilter == CategoryFilter.Semua ||
              (_categoryFilter == CategoryFilter.Makanan &&
                  productCategory == 'makanan') ||
              (_categoryFilter == CategoryFilter.Minuman &&
                  productCategory == 'minuman')) &&
          (menuName.contains(_searchQuery));
    }).toList();
  }

  List<DocumentSnapshot> _sortProducts(
      List<DocumentSnapshot> products, String sortCriteria) {
    switch (sortCriteria) {
      case 'terbaru':
        products.sort((a, b) {
          var aDate = (a['updatedAt'] as Timestamp).toDate();
          var bDate = (b['updatedAt'] as Timestamp).toDate();
          return bDate.compareTo(aDate);
        });
        break;
      case 'terlama':
        products.sort((a, b) {
          var aDate = (a['updatedAt'] as Timestamp).toDate();
          var bDate = (b['updatedAt'] as Timestamp).toDate();
          return aDate.compareTo(bDate);
        });
        break;
      case 'A-Z':
        products.sort((a, b) {
          var aName = a['menu'].toString().toLowerCase();
          var bName = b['menu'].toString().toLowerCase();
          return aName.compareTo(bName);
        });
        break;
      case 'Z-A':
        products.sort((a, b) {
          var aName = a['menu'].toString().toLowerCase();
          var bName = b['menu'].toString().toLowerCase();
          return bName.compareTo(aName);
        });
        break;
      case 'stok terendah':
        products.sort((a, b) => a['stok'].compareTo(b['stok']));
        break;
      case 'stok terbanyak':
        products.sort((a, b) => b['stok'].compareTo(a['stok']));
        break;
      default:
        break;
    }
    return products;
  }

  int _getNumberOfTabs() {
    return CategoryFilter.values.length;
  }

  void _showSortingOverlay(BuildContext context) {
    showSortingOverlay(
      context,
      _sortingCriteria,
      (String sortingCriteria) {
        setState(() {
          _sortingCriteria = sortingCriteria;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: DefaultTabController(
        length: _getNumberOfTabs(),
        child: Scaffold(
          backgroundColor: Col.backgroundColor,
          appBar: AppBar(
            elevation: 2,
            backgroundColor: Col.primaryColor,
            foregroundColor: Col.whiteColor,
            surfaceTintColor: Col.primaryColor,
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Col.whiteColor,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Col.whiteColor.withOpacity(0.1),
                            contentPadding: const EdgeInsets.all(8.0),
                            hintText: 'Cari produk',
                            hintStyle: TextStyle(
                              color: Col.whiteColor.withOpacity(.50),
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            prefixIconColor: Col.whiteColor.withOpacity(.50),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
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
                          visible: _searchQuery.isNotEmpty,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                              });
                              _searchController.clear();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.clear,
                                color: Col.whiteColor.withOpacity(0.50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Urutkan',
                onPressed: () {
                  _showSortingOverlay(context);
                },
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
            bottom: TabBar(
              labelColor: Col.secondaryColor,
              unselectedLabelColor: Col.secondaryColor.withOpacity(0.5),
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Col.primaryColor,
              tabs: [
                for (int i = 0; i < _getNumberOfTabs(); i++)
                  Tab(
                    child: Text(
                      _getCategoryFromIndex(i).toString().split('.').last
                        ..toUpperCase(),
                      style: const TextStyle(
                        fontWeight: Fw.regular,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
                key: UniqueKey(),
                children: [
                  for (int i = 0; i < _getNumberOfTabs(); i++)
                    StreamBuilder<QuerySnapshot>(
                      stream: _produkCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            _isRefreshing) {
                          return Column(
                            children: List.generate(
                              3,
                              (index) => Skeletonizer(
                                enabled: true,
                                child: Card(
                                  elevation: 0,
                                  color: Col.secondaryColor,
                                  shadowColor: Col.greyColor.withOpacity(0.10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Skeleton.leaf(
                                          child: SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Container(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Skeleton nama produk',
                                                style: Typo
                                                    .emphasizedBodyTextStyle,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                'Skeleton stok',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Skeleton update produkkkkkkkkk',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Error fetching data',
                              style: TextStyle(color: Col.redAccent),
                            ),
                          );
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Tidak ada produk',
                              style: TextStyle(color: Col.greyColor),
                            ),
                          );
                        }

                        List<DocumentSnapshot> filteredProducts =
                            _filterProducts(snapshot.data!);
                        List<DocumentSnapshot> categoryProducts =
                            filteredProducts.where((document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String productCategory =
                              data['kategori'].toString().toLowerCase();

                          return _getCategoryFromIndex(i) ==
                                  CategoryFilter.Semua ||
                              (_getCategoryFromIndex(i) ==
                                      CategoryFilter.Makanan &&
                                  productCategory == 'makanan') ||
                              (_getCategoryFromIndex(i) ==
                                      CategoryFilter.Minuman &&
                                  productCategory == 'minuman');
                        }).toList();

                        List<DocumentSnapshot> sortedProducts =
                            _sortProducts(categoryProducts, _sortingCriteria);

                        bool hasLowStockProducts = sortedProducts
                            .any((product) => (product['stok'] ?? 0) < 5);

                        return RefreshIndicator(
                          backgroundColor: Col.secondaryColor,
                          color: Col.primaryColor,
                          onRefresh: _refreshData,
                          child: ListView(
                            key: UniqueKey(),
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              if (hasLowStockProducts)
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'Produk yang Stoknya Dikit Banget 😲',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              if (hasLowStockProducts)
                                SizedBox(
                                  height: 245,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: sortedProducts.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        return const SizedBox(width: 8);
                                      } else {
                                        DocumentSnapshot document =
                                            sortedProducts[index];
                                        Map<String, dynamic> data = document
                                            .data() as Map<String, dynamic>;
                                        String documentId = document.id;

                                        // Check if stock is less than 5
                                        bool isLowStock =
                                            (data['stok'] ?? 0) < 5;

                                        return isLowStock
                                            ? LowStockProductsCard(
                                                document: document,
                                                isLowStock: isLowStock,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailProdukPage(
                                                        documentId: documentId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : const SizedBox();
                                      }
                                    },
                                  ),
                                ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Stok yang aman nih yee 🙌',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ListView.builder(
                                key: UniqueKey(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8.0),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: sortedProducts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot document =
                                      sortedProducts[index];
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String documentId = document.id;

                                  // Check if stock is greater than or equal to 5
                                  bool isHighStock = (data['stok'] ?? 0) >= 5;

                                  return isHighStock
                                      ? HighStockProductsCard(
                                          document: document,
                                          isHighStock: isHighStock,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailProdukPage(
                                                  documentId: documentId,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const SizedBox(); // Skip if low stock
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  // gradien
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                        0.0,
                        1.0
                      ],
                          colors: [
                        Col.secondaryColor.withOpacity(0.1),
                        Col.secondaryColor,
                      ])),
                  height: 50,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.share),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShareProduk(),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
