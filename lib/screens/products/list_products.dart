import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';
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
  const ListProdukPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListProdukPageState createState() => _ListProdukPageState();
}

class _ListProdukPageState extends State<ListProdukPage> {
  TextEditingController _searchController = TextEditingController();

  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;
  CategoryFilter _categoryFilter = CategoryFilter.Semua;
  SortingOption _sortingOption = SortingOption.Terbaru;
  String _searchQuery = '';
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
  }

  void _resetCategoryFilter() {
    setState(() {
      _categoryFilter = CategoryFilter.Semua;
    });
  }

  void _resetSortingOption() {
    setState(() {
      _sortingOption = SortingOption.Terbaru;
    });
  }

  void _updateSnapshot(AsyncSnapshot<QuerySnapshot> newSnapshot) {
    setState(() {});
  }

  Future<void> _deleteProduct(String documentId) async {
    await _produkCollection.doc(documentId).delete();
  }

  Future<void> _refreshData() async {
    // Set state to indicate refreshing
    setState(() {
      _isRefreshing = true;
      _enabled = false;
      _resetCategoryFilter();
      _resetSortingOption();
    });

    if (!mounted) {
      return; // Check if the widget is still mounted
    }

    try {
      setState(() {
        _isRefreshing = false;
        _enabled = true;
      });

      // Fetch or refresh data here (e.g., refetch Firestore data)
      await Future.delayed(const Duration(seconds: 2)); // Simulating a delay
    } catch (error) {
      // Handle error in case of any issues during refresh
      print('Error refreshing data: $error');
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

  void _showFilterSortingOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4, // Adjusted initial size
          maxChildSize: 0.4, // Adjusted max size
          minChildSize: 0.1,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: DesignSystem.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: DesignSystem.greyColor.withOpacity(.50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      Row(children: [
                        buildSortingAndFilteringButton(
                          label: 'Semua',
                          icon: Icons.category,
                          onPressed: () {
                            _setcategoryOption(CategoryFilter.Semua);
                            _refreshData();
                            Navigator.pop(context);
                          },
                          isActive: _categoryFilter == CategoryFilter.Semua,
                        ),
                        const SizedBox(width: 10),
                        buildSortingAndFilteringButton(
                          label: 'Makanan',
                          icon: Icons.restaurant,
                          onPressed: () {
                            _setcategoryOption(CategoryFilter.Makanan);
                            Navigator.pop(context);
                          },
                          isActive: _categoryFilter == CategoryFilter.Makanan,
                        ),
                        const SizedBox(width: 10),
                        buildSortingAndFilteringButton(
                          label: 'Minuman',
                          icon: Icons.local_drink_outlined,
                          onPressed: () {
                            _setcategoryOption(CategoryFilter.Minuman);
                            Navigator.pop(context);
                          },
                          isActive: _categoryFilter == CategoryFilter.Minuman,
                        ),
                      ]),
                      const SizedBox(height: 20),
                      const Text(
                        'Urutkan berdasarkan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: DesignSystem.blackColor,
                        ),
                      ),
                      Row(children: [
                        buildSortingAndFilteringButton(
                          label: 'Terbaru',
                          icon: Icons.flash_auto_outlined,
                          onPressed: () {
                            _setSortingOption(SortingOption.Terbaru);
                            Navigator.pop(context);
                          },
                          isActive: _sortingOption == SortingOption.Terbaru,
                        ),
                        const SizedBox(width: 10),
                        buildSortingAndFilteringButton(
                          label: 'A-Z',
                          icon: Icons.sort_by_alpha,
                          onPressed: () {
                            _setSortingOption(SortingOption.AZ);
                            Navigator.pop(context);
                          },
                          isActive: _sortingOption == SortingOption.AZ,
                        ),
                        const SizedBox(width: 10),
                        buildSortingAndFilteringButton(
                          label: 'Z-A',
                          icon: Icons.sort_by_alpha_outlined,
                          onPressed: () {
                            _setSortingOption(SortingOption.ZA);
                            Navigator.pop(context);
                          },
                          isActive: _sortingOption == SortingOption.ZA,
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSortingAndFilteringButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return ElevatedButton(
      style: isActive
          ? ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            )
          : ElevatedButton.styleFrom(
              foregroundColor: DesignSystem.greyColor,
              backgroundColor: DesignSystem.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
            ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  void _setSortingOption(SortingOption option) {
    setState(() {
      _sortingOption = option;
    });
  }

  void _setcategoryOption(CategoryFilter option) {
    setState(() {
      _categoryFilter = option;
    });
  }

  void _resetFilters() {
    setState(() {
      _categoryFilter = CategoryFilter.Semua;
      _sortingOption = SortingOption.Terbaru;
      _refreshData();
    });
  }

  List<DocumentSnapshot> _filterProducts(QuerySnapshot snapshot) {
    return snapshot.docs.where((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final menuName = data['menu'].toString().toLowerCase();
      final productCategory = data['kategori']
          .toString()
          .toLowerCase(); // Change to the appropriate field in Firestore

      return (_categoryFilter == CategoryFilter.Semua ||
              (_categoryFilter == CategoryFilter.Makanan &&
                  productCategory == 'makanan') ||
              (_categoryFilter == CategoryFilter.Minuman &&
                  productCategory == 'minuman')) &&
          (menuName.contains(_searchQuery));
    }).toList();
  }

  List<DocumentSnapshot> _sortProducts(List<DocumentSnapshot> products) {
    return products
      ..sort((a, b) {
        Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
        Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 40,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: DesignSystem.blackColor,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: DesignSystem.greyColor.withOpacity(0.1),
                      contentPadding: const EdgeInsets.all(8.0),
                      hintText: 'Cari produk',
                      hintStyle: const TextStyle(
                        color: DesignSystem.greyColor,
                        fontSize: 14.0,
                      ),
                      prefixIcon: const Icon(Icons.search),
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
                    visible: _searchQuery.isNotEmpty,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = ''; // Clear the search query
                        });
                        // Clear the text field
                        _searchController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/comingsoon');
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: _categoryFilter != CategoryFilter.Semua
                          ? DesignSystem.primaryColor
                          : DesignSystem.blackColor,
                      elevation: 0.2,

                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3), // Adjusted padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () {
                      _showFilterSortingOverlay();
                    },
                    child: Row(
                      children: [
                        Text(
                          _categoryFilter != CategoryFilter.Semua
                              ? _categoryFilter.toString().split('.').last
                              : 'Filter',
                          style: const TextStyle(
                            fontSize: 14, // Adjusted font size
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more_outlined,
                        ),
                      ],
                    )),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: _sortingOption != SortingOption.Terbaru
                        ? DesignSystem.primaryColor
                        : DesignSystem.blackColor,
                    elevation: 0.2,

                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3), // Adjusted padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () {
                    _showFilterSortingOverlay();
                  },
                  child: Row(
                    children: [
                      Text(
                        _sortingOption != SortingOption.Terbaru
                            ? _sortingOption.toString().split('.').last
                            : 'Sort',
                        style: const TextStyle(
                          fontSize: 14, // Adjusted font size
                        ),
                      ),
                      const SizedBox(width: 4), // Adjusted spacing
                      const Icon(
                        Icons.expand_more_outlined,
                      ),
                    ],
                  ),
                ),
                if (_categoryFilter != CategoryFilter.Semua ||
                    _sortingOption != SortingOption.Terbaru)
                  const SizedBox(width: 8),
                if (_categoryFilter != CategoryFilter.Semua ||
                    _sortingOption != SortingOption.Terbaru)
                  TextButton(
                    onPressed: () {
                      _resetFilters();
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: DesignSystem.primaryColor,
                        fontSize: 14, // Adjusted font size
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: DesignSystem.primaryColor,
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
                        child: Container(),
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
                    List<DocumentSnapshot> sortedProducts =
                        _sortProducts(filteredProducts);

                    return Scrollbar(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        physics: const BouncingScrollPhysics(),
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

                          return InkWell(
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
                                          width: 300,
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
                                        const SizedBox(height: 5),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['menu'],
                                                style:
                                                    DesignSystem.titleTextStyle,
                                                overflow: TextOverflow.ellipsis,
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
