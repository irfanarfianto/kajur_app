import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';
import 'package:kajur_app/screens/products/widget/sorting_show.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum CategoryFilter {
  Semua,
  Makanan,
  Minuman,
}

enum SortingOption {
  Terbaru,
  AZ,
  ZA,
}

class ListProdukPage extends StatefulWidget {
  const ListProdukPage({Key? key}) : super(key: key);

  @override
  _ListProdukPageState createState() => _ListProdukPageState();
}

class _ListProdukPageState extends State<ListProdukPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;
  CategoryFilter _categoryFilter = CategoryFilter.Semua;
  SortingOption _sortingOption = SortingOption.Terbaru;
  String _searchQuery = '';
  bool isSelectedTerbaru = true;
  bool isSelectedAZ = false;
  bool isSelectedZA = false;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
  }

  @override
  bool get wantKeepAlive => true;

  void _resetSortingOption() {
    setState(() {
      _sortingOption = SortingOption.Terbaru;
      isSelectedTerbaru = false;
      isSelectedAZ = false;
      isSelectedZA = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
      _resetSortingOption();
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

  void _showSortingOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SortingOverlay(
              isSelectedTerbaru: isSelectedTerbaru,
              isSelectedAZ: isSelectedAZ,
              isSelectedZA: isSelectedZA,
              onTerbaruChanged: (value) {
                setState(() {
                  isSelectedTerbaru = value!;
                  isSelectedAZ = false;
                  isSelectedZA = false;
                });
              },
              onAZChanged: (value) {
                setState(() {
                  isSelectedAZ = value!;
                  isSelectedTerbaru = false;
                  isSelectedZA = false;
                });
              },
              onZAChanged: (value) {
                setState(() {
                  isSelectedZA = value!;
                  isSelectedTerbaru = false;
                  isSelectedAZ = false;
                });
              },
              onReset: () {
                setState(() {
                  _resetSortingOption(); // Panggil fungsi reset di sini
                });
              },
              onTerapkan: () {
                _applySortingOption();
                _refreshData();
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _applySortingOption() {
    if (isSelectedTerbaru) {
      _setSortingOption(SortingOption.Terbaru);
    } else if (isSelectedAZ) {
      _setSortingOption(SortingOption.AZ);
    } else if (isSelectedZA) {
      _setSortingOption(SortingOption.ZA);
    }
  }

  void _setSortingOption(SortingOption option) {
    setState(() {
      _sortingOption = option;
    });
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

  List<DocumentSnapshot> _sortProducts(List<DocumentSnapshot> products) {
    return List.from(products)
      ..sort((a, b) {
        Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
        Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

        if (_sortingOption == SortingOption.Terbaru) {
          Timestamp timeA = dataA['updatedAt'] ?? Timestamp.now();
          Timestamp timeB = dataB['updatedAt'] ?? Timestamp.now();
          return timeB.compareTo(timeA);
        } else if (_sortingOption == SortingOption.AZ) {
          return dataA['menu']
              .toString()
              .toLowerCase()
              .compareTo(dataB['menu'].toString().toLowerCase());
        } else {
          return dataB['menu']
              .toString()
              .toLowerCase()
              .compareTo(dataA['menu'].toString().toLowerCase());
        }
      });
  }

  int _getNumberOfTabs() {
    return CategoryFilter.values.length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: DefaultTabController(
        length: _getNumberOfTabs(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: DesignSystem.primaryColor,
            foregroundColor: DesignSystem.whiteColor,
            surfaceTintColor: DesignSystem.primaryColor,
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
                            color: DesignSystem.whiteColor,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: DesignSystem.whiteColor.withOpacity(0.1),
                            contentPadding: const EdgeInsets.all(8.0),
                            hintText: 'Cari produk',
                            hintStyle: TextStyle(
                              color: DesignSystem.whiteColor.withOpacity(.50),
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            prefixIconColor:
                                DesignSystem.whiteColor.withOpacity(.50),
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
                              child: const Icon(
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
              ),
              IconButton(
                onPressed: () {
                  _showSortingOverlay();
                },
                icon: const Icon(Icons.sort_outlined),
              ),
            ],
            bottom: TabBar(
              tabs: [
                for (int i = 0; i < _getNumberOfTabs(); i++)
                  Tab(
                    child: Text(
                      _getCategoryFromIndex(i).toString().split('.').last
                        ..toUpperCase(),
                      style: TextStyle(
                        color: _categoryFilter == _getCategoryFromIndex(i)
                            ? DesignSystem.secondaryColor
                            : DesignSystem.whiteColor,
                        fontWeight: DesignSystem.regular,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: TabBarView(
            key: UniqueKey(),
            children: [
              for (int i = 0; i < _getNumberOfTabs(); i++)
                FutureBuilder<QuerySnapshot>(
                  future: _produkCollection.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        _isRefreshing) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada produk',
                          style: TextStyle(color: DesignSystem.whiteColor),
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

                      return _getCategoryFromIndex(i) == CategoryFilter.Semua ||
                          (_getCategoryFromIndex(i) == CategoryFilter.Makanan &&
                              productCategory == 'makanan') ||
                          (_getCategoryFromIndex(i) == CategoryFilter.Minuman &&
                              productCategory == 'minuman');
                    }).toList();

                    List<DocumentSnapshot> sortedProducts =
                        _sortProducts(categoryProducts);

                    return RefreshIndicator(
                      backgroundColor: DesignSystem.secondaryColor,
                      color: DesignSystem.primaryColor,
                      onRefresh: _refreshData,
                      child: GridView.builder(
                        key: UniqueKey(),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: sortedProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = sortedProducts[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String documentId = document.id;

                          return Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailProdukPage(
                                      documentId: documentId,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'product_image_$documentId',
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
                                            height: 150,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: DesignSystem.greyColor
                                                      .withOpacity(.10),
                                                  offset: const Offset(0, 5),
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
                                          const SizedBox(height: 3),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['menu'],
                                                  style: DesignSystem
                                                      .titleTextStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: data['stok'] == 0
                                                  ? DesignSystem.redAccent
                                                      .withOpacity(.80)
                                                  : data['stok'] < 5
                                                      ? DesignSystem
                                                          .primaryColor
                                                          .withOpacity(.80)
                                                      : DesignSystem
                                                          .primaryColor
                                                          .withOpacity(.80),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              data['stok'] == 0
                                                  ? 'Stok habis'
                                                  : '${data['stok'] ?? 0}',
                                              style: const TextStyle(
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
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
