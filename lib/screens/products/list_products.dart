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
  final TextEditingController _searchController = TextEditingController();

  late CollectionReference _produkCollection;
  late bool _isRefreshing = false;
  CategoryFilter _categoryFilter = CategoryFilter.Semua;
  SortingOption _sortingOption = SortingOption.Terbaru;
  String _searchQuery = '';
  bool _enabled = false;
  bool isSelectedTerbaru = true;
  bool isSelectedAZ = false;
  bool isSelectedZA = false;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
  }

  void _resetSortingOption() {
    setState(() {
      _sortingOption = SortingOption.Terbaru;
    });
  }

  Future<void> _refreshData() async {
    // Set state to indicate refreshing
    setState(() {
      _isRefreshing = true;
      _enabled = false;

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

  void _showSortingOverlay() {
    bool isSelectedTerbaru = _sortingOption == SortingOption.Terbaru;
    bool isSelectedAZ = _sortingOption == SortingOption.AZ;
    bool isSelectedZA = _sortingOption == SortingOption.ZA;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.4,
              maxChildSize: 0.4,
              minChildSize: 0.1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: DesignSystem.backgroundColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
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
                            'Urutkan berdasarkan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.blackColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            activeColor: DesignSystem.primaryColor,
                            title: const Text(
                              'Terbaru',
                              style: DesignSystem.subtitleTextStyle,
                            ),
                            value: isSelectedTerbaru,
                            onChanged: (value) {
                              setState(() {
                                isSelectedTerbaru = value!;
                                isSelectedAZ = false;
                                isSelectedZA = false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            activeColor: DesignSystem.primaryColor,
                            title: const Text(
                              'A-Z',
                              style: DesignSystem.subtitleTextStyle,
                            ),
                            value: isSelectedAZ,
                            onChanged: (value) {
                              setState(() {
                                isSelectedAZ = value!;
                                isSelectedTerbaru = false;
                                isSelectedZA = false;
                              });
                            },
                          ),
                          CheckboxListTile(
                            activeColor: DesignSystem.primaryColor,
                            title: const Text(
                              'Z-A',
                              style: DesignSystem.subtitleTextStyle,
                            ),
                            value: isSelectedZA,
                            onChanged: (value) {
                              setState(() {
                                isSelectedZA = value!;
                                isSelectedTerbaru = false;
                                isSelectedAZ = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: DesignSystem.greyColor,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  // Reset Sorting
                                  setState(() {
                                    isSelectedTerbaru = false;
                                    isSelectedAZ = false;
                                    isSelectedZA = false;
                                  });
                                },
                                child: const Text('Reset'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Apply Sorting
                                    if (isSelectedTerbaru) {
                                      _setSortingOption(SortingOption.Terbaru);
                                    } else if (isSelectedAZ) {
                                      _setSortingOption(SortingOption.AZ);
                                    } else if (isSelectedZA) {
                                      _setSortingOption(SortingOption.ZA);
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Terapkan'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget filteringButton({
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isActive ? DesignSystem.secondaryColor : Colors.transparent,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? DesignSystem.secondaryColor
                      : DesignSystem.whiteColor,
                  fontWeight: DesignSystem.regular,
                ),
              ),
            ),
          ),
        ),
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
                        color: DesignSystem.blackColor,
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
          ),
          IconButton(
            onPressed: () {
              _showSortingOverlay();
            },
            icon: const Icon(Icons.sort_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: DesignSystem.primaryColor,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  filteringButton(
                    label: 'Semua',
                    onPressed: () {
                      _setcategoryOption(CategoryFilter.Semua);
                    },
                    isActive: _categoryFilter == CategoryFilter.Semua,
                  ),
                  filteringButton(
                    label: 'Makanan',
                    onPressed: () {
                      _setcategoryOption(CategoryFilter.Makanan);
                    },
                    isActive: _categoryFilter == CategoryFilter.Makanan,
                  ),
                  filteringButton(
                    label: 'Minuman',
                    onPressed: () {
                      _setcategoryOption(CategoryFilter.Minuman);
                    },
                    isActive: _categoryFilter == CategoryFilter.Minuman,
                  ),
                ]),
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
                      child: ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(overscroll: false),
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          physics: const ClampingScrollPhysics(),
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
                                                    color: DesignSystem
                                                        .greyColor
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
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
                                                  color:
                                                      DesignSystem.whiteColor,
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
