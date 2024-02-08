import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/details_products.dart';
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

  void _showSortingOverlay() {
    showModalBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    )),
                const SizedBox(width: 16),
                const Text('Urutkan Berdasarkan', style: Typo.headingTextStyle),
              ],
            ),
            SizedBox(
              height: 12,
              child: Divider(
                thickness: 2,
                color: Col.greyColor.withOpacity(0.1),
              ),
            ),
            Wrap(
              children: [
                ListTile(
                  title: const Text('🆕 Baru ditambahkan'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'terbaru';
                    });
                  },
                ),
                ListTile(
                  title: const Text('🙌 Sudah lama'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'terlama';
                    });
                  },
                ),
                Divider(
                  thickness: 1,
                  color: Col.greyColor.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Urutan A-Z'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'A-Z';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Urutan Z-A'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'Z-A';
                    });
                  },
                ),
                Divider(
                  thickness: 1,
                  color: Col.greyColor.withOpacity(0.1),
                ),
                ListTile(
                  title: const Text('Stok Terendah'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'stok terendah';
                    });
                  },
                ),
                ListTile(
                  title: const Text('Stok Terbanyak'),
                  onTap: () {
                    setState(() {
                      _sortingCriteria = 'stok terbanyak';
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
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

  Future<void> _updateStock(String documentId, int newStock) async {
    try {
      // Fetch the old product data before updating the stock
      DocumentSnapshot oldProductSnapshot =
          await _produkCollection.doc(documentId).get();
      Map<String, dynamic> oldProductData =
          oldProductSnapshot.data() as Map<String, dynamic>;

      // Perform the stock update
      await FirebaseFirestore.instance
          .collection('kantin')
          .doc(documentId)
          .update({
        'stok': newStock,
        'updatedAt': DateTime.now(),
      });

      // Record activity log using the old product data
      await _recordActivityLog(
        action: 'Update Stok',
        productId: documentId,
        oldProductData: oldProductData,
        newProductData: {
          'stok': newStock,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Show success message or notification if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Stok berhasil diperbarui.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // Handle errors if they occur
      print('Error updating stock: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui stok.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required String productId,
    required Map<String, dynamic> oldProductData,
    required Map<String, dynamic> newProductData,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
            message: 'User not authenticated', code: '');
      }

      String userId = user.uid;
      String userName = user.displayName ?? 'Unknown User';

      // Create reference to activity log collection
      CollectionReference activityLogCollection =
          FirebaseFirestore.instance.collection('activity_log');

      // Record activity log to collection
      await activityLogCollection.add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'productId': productId,
        'productName': oldProductData['menu'],
        'oldProductData': oldProductData,
        'newProductData': newProductData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal merekam aktivitas.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUpdateStokDialog(
      String documentId, String productName, int lastStock, String imageUrl) {
    TextEditingController stokController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Col.secondaryColor,
          backgroundColor: Col.secondaryColor,
          title: Row(
            children: [
              const Icon(
                Icons.update,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text('Update Stok', style: Typo.titleTextStyle),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'product_image_$documentId',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName.isEmpty ? 'Loading...' : productName,
                              style: Typo.emphasizedBodyTextStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            Text(
                              lastStock == 0
                                  ? 'Stok sudah habis'
                                  : 'Sisa stok $lastStock',
                              style: TextStyle(
                                fontSize: 14,
                                color: lastStock == 0
                                    ? Col.redAccent
                                    : Col.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok Baru',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok harus diisi';
                        }
                        // Validasi jika nilai bukan angka
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        // Validasi jika nilai negatif
                        if (int.parse(value) < 0) {
                          return 'Stok tidak boleh negatif';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  int newStock = int.tryParse(stokController.text) ?? 0;
                  _updateStock(documentId, newStock);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
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
                              child: const Icon(
                                Icons.clear,
                                color: Col.greyColor,
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
                icon: const Icon(Icons.filter_alt),
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
          body: TabBarView(
            key: UniqueKey(),
            children: [
              for (int i = 0; i < _getNumberOfTabs(); i++)
                StreamBuilder<QuerySnapshot>(
                  stream: _produkCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
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
                                            style: Typo.emphasizedBodyTextStyle,
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

                      return _getCategoryFromIndex(i) == CategoryFilter.Semua ||
                          (_getCategoryFromIndex(i) == CategoryFilter.Makanan &&
                              productCategory == 'makanan') ||
                          (_getCategoryFromIndex(i) == CategoryFilter.Minuman &&
                              productCategory == 'minuman');
                    }).toList();

                    List<DocumentSnapshot> sortedProducts =
                        _sortProducts(categoryProducts, _sortingCriteria);

                    return RefreshIndicator(
                      backgroundColor: Col.secondaryColor,
                      color: Col.primaryColor,
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        key: UniqueKey(),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        itemCount: sortedProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document = sortedProducts[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String documentId = document.id;

                          return Card(
                            elevation: 0,
                            color: Col.secondaryColor,
                            shadowColor: Col.greyColor.withOpacity(0.10),
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: 'product_image_$documentId',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          data['image'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['menu'],
                                            style: Typo.emphasizedBodyTextStyle,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            data['stok'] == 0
                                                ? 'Stok sudah habis'
                                                : 'Sisa stok ${data['stok'] ?? 0}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: data['stok'] == 0
                                                  ? Col.redAccent
                                                  : Col.greyColor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '*Diperbarui ${DateFormat('dd MMM y HH:mm', 'id_ID').format(data['updatedAt']?.toDate() ?? DateTime.now())}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Col.greyColor,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 100,
                                      child: InkWell(
                                        onTap: () {
                                          _showUpdateStokDialog(
                                              documentId,
                                              data['menu'],
                                              data['stok'],
                                              data['image']);
                                        },
                                        child: const SizedBox(
                                          width: 60,
                                          height: 100,
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Col.greyColor,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    )
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
            ],
          ),
        ),
      ),
    );
  }
}
