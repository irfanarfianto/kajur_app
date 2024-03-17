import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/components/produk/detail_produk.dart';
import 'package:kajur_app/components/produk/update_stock_dialog.dart';
import 'package:kajur_app/screens/products/list/details_cart.dart';
import 'package:kajur_app/utils/animation/route/slide_up.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/products/details/details_products_page.dart';
import 'package:kajur_app/components/produk/sorting_overlay.dart';
import 'package:kajur_app/screens/products/list/products_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum CategoryFilter {
  Semua,
  Makanan,
  Minuman,
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
  final CategoryFilter _categoryFilter = CategoryFilter.Semua;
  String _searchQuery = '';
  String _sortingCriteria = 'default';
  final List<Map<String, dynamic>> _cartItems = [];
  bool _isBottomAppBarVisible = false;

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
      // Simulate delay
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
    return CategoryFilter.values[index];
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
      case 'baru':
        products.sort((a, b) {
          var aDate = (a['createdAt'] as Timestamp).toDate();
          var bDate = (b['createdAt'] as Timestamp).toDate();
          return bDate.compareTo(aDate);
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
        // default sorting
        products.sort((a, b) {
          var aDate = (a['updatedAt'] as Timestamp).toDate();
          var bDate = (b['updatedAt'] as Timestamp).toDate();
          return bDate.compareTo(aDate);
        });
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

  void _addToCart(DocumentSnapshot document, Map<String, dynamic> data) {
    setState(() {
      _cartItems.add({
        'document': document,
        'data': data,
        'documentId': document.id,
      });
      _isBottomAppBarVisible = true;
    });
  }

  void _removeFromCart(DocumentSnapshot document) {
    setState(() {
      _cartItems.removeWhere((item) => item['document'].id == document.id);
      _isBottomAppBarVisible = _cartItems.isNotEmpty;
    });
  }

  double _calculateTotalHargaPokok() {
    return _cartItems.fold<double>(
        0.0, (total, item) => total += item['data']['hargaPokok']);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double totalHargaPokok = _calculateTotalHargaPokok();
    String formattedTotalHargaPokok =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(totalHargaPokok);

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
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Col.whiteColor.withOpacity(0.1),
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
                children: [
                  for (int i = 0; i < _getNumberOfTabs(); i++)
                    StreamBuilder<QuerySnapshot>(
                      stream: _produkCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            _isRefreshing) {
                          return _buildSkeletonList();
                        }

                        if (snapshot.hasError) {
                          return _buildErrorMessage();
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return _buildNoProductMessage();
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

                        return _buildProductList(sortedProducts);
                      },
                    )
                ],
              ),
              if (_cartItems.isEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 1.0],
                        colors: [
                          Col.secondaryColor.withOpacity(0.1),
                          Col.secondaryColor,
                        ],
                      ),
                    ),
                    height: 50,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildBottomAppBar(formattedTotalHargaPokok),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
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
                        borderRadius: BorderRadius.circular(8),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildErrorMessage() {
    return const Center(
      child: Text(
        'Error fetching data',
        style: TextStyle(color: Col.redAccent),
      ),
    );
  }

  Widget _buildNoProductMessage() {
    return const Center(
      child: Text(
        'Tidak ada produk',
        style: TextStyle(color: Col.greyColor),
      ),
    );
  }

  Widget _buildProductList(List<DocumentSnapshot> sortedProducts) {
    return RefreshIndicator(
      backgroundColor: Col.secondaryColor,
      color: Col.primaryColor,
      onRefresh: _refreshData,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 25,
            childAspectRatio: 0.72,
          ),
          itemCount: sortedProducts.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = sortedProducts[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String documentId = document.id;

            bool isInCart =
                _cartItems.any((item) => item['document'].id == document.id);

            return ProductsCard(
              document: document,
              onTap: () {
                showUpdateStokDialog(
                  context,
                  documentId,
                  data['menu'],
                  data['stok'],
                  document['image'],
                );
              },
              addCart: () {
                _addToCart(document, data);
              },
              removeCart: () {
                _removeFromCart(document);
              },
              isInCart: isInCart,
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  backgroundColor: Col.backgroundColor,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: DetailProduk(
                        document: document,
                        imageUrl: data['image'],
                        productName: data['menu'],
                        onTapDescription: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            SlideUpRoute(
                              page: DetailProdukPage(
                                documentId: documentId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(String formattedTotalHargaPokok) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height:
          _isBottomAppBarVisible ? 70 : 0, // Adjust height based on visibility
      child: BottomAppBar(
        elevation: 1,
        color: Col.secondaryColor,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartItemDetail(
                  cartItems: _cartItems,
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 210,
                child: Row(
                  children: [
                    Text('Keranjang ',
                        style: Typo.bodyTextStyle
                            .copyWith(fontWeight: Fw.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('•',
                        style: Typo.bodyTextStyle
                            .copyWith(fontWeight: Fw.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      '${_cartItems.length} Produk terpilih',
                      style: Typo.bodyTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Text(
                formattedTotalHargaPokok,
                style: Typo.bodyTextStyle
                    .copyWith(fontWeight: Fw.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
