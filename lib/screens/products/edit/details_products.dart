import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/products/edit/edit_products.dart';

class DetailProdukPage extends StatefulWidget {
  final String documentId;

  const DetailProdukPage({super.key, required this.documentId});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  late CollectionReference _produkCollection;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _userRole = userData['role'];
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _deleteProduct(String documentId) async {
    setState(() {
    });

    try {
      DocumentSnapshot productSnapshot =
          await _produkCollection.doc(documentId).get();
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      await _recordActivityLog(
        action: 'Hapus Produk',
        productId: documentId,
        productName: productData['menu'],
        productData: productData,
      );

      setState(() {
      });

      await _produkCollection.doc(documentId).delete();
      showToast(message: 'Produk berhasil dihapus');
    } catch (e) {
      setState(() {
      });
      showToast(message: 'Terjadi kesalahan saat menghapus produk');
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required String productId,
    required String productName,
    required Map<String, dynamic> productData,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;
      String? userName = user?.displayName ?? 'Unknown User';

      CollectionReference activityLogCollection =
          FirebaseFirestore.instance.collection('activity_log');

      await activityLogCollection.add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'productId': productId,
        'productName': productName,
        'productData': productData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording activity log: $e');
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) {
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (error) {
      // Handle error
    } finally {
      if (mounted) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: _buildProductDetails(),
    );
  }

  Widget _buildProductDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: _produkCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        var documents = snapshot.data!.docs;
        var matchingDocuments =
            documents.where((doc) => doc.id == widget.documentId);
        if (matchingDocuments.isNotEmpty) {
          var data = matchingDocuments.first.data() as Map<String, dynamic>;
          String productName = data['menu'] ?? 'Product Name';

          Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
          Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

          return Scaffold(
            backgroundColor: Col.secondaryColor,
            bottomNavigationBar: _userRole == 'staf' || _userRole == 'admin'
                ? _buildBottomAppBar()
                : null,
            body: CustomScrollView(slivers: [
              SliverAppBar(
                iconTheme: const IconThemeData(
                  color: Col.whiteColor,
                  size: 24,
                ),
                expandedHeight: 300,
                floating: true,
                pinned: true,
                foregroundColor: Col.whiteColor,
                title: Text(
                  productName,
                ),
                scrolledUnderElevation: 2,
                automaticallyImplyLeading: true,
                centerTitle: true,
                backgroundColor: Col.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () {
                      _showImageDialog(context, data['image']);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'product_image_${widget.documentId}',
                          child: SizedBox(
                            height: 300,
                            width: 300,
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: data['image'],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Detail produk', style: Typo.titleTextStyle),
                              Row(
                                children: [
                                  StatusBadge(
                                    label: data['kategori'] == 'Makanan'
                                        ? 'Makanan'
                                        : data['kategori'] == 'Minuman'
                                            ? 'Minuman'
                                            : 'Kategori Tidak Diketahui',
                                    color: data['kategori'] == 'Makanan'
                                        ? Colors.green
                                        : data['kategori'] == 'Minuman'
                                            ? Col.primaryColor
                                            : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: data['stok'] == 0
                                        ? 'Stok habis'
                                        : 'Sisa stok ${data['stok'] ?? 0}',
                                    color: data['stok'] == 0
                                        ? Col.redAccent
                                        : data['stok'] < 5
                                            ? Col.primaryColor
                                            : Col.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Jual'),
                            Row(
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(data['hargaJual']),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Col.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' +${NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(data['profitSatuan'].toInt())}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Col.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Harga Pokok / Beli'),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(data['hargaPokok']),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Col.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(
                              height: 30, // Adjust the height as needed
                              child: VerticalDivider(
                                color: Col.greyColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Qty / isi'),
                                Text(
                                  '${data['jumlahIsi']}pcs',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Col.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            const SizedBox(
                              height: 30,
                              child: VerticalDivider(
                                color: Col.greyColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Perkiraan Total Profit'),
                                Text(
                                  '+${NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(data['totalProfit'].toInt())}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Col.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deskripsi produk',
                                style: Typo.subtitleTextStyle),
                            ReadMoreText(
                              '${data['deskripsi'] ?? 'Tidak ada deskripsi'}',
                              trimLines: 3,
                              style: Typo.bodyTextStyle,
                              colorClickableText: Col.primaryColor,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Baca selengkapnya',
                              trimExpandedText: 'Tutup',
                              moreStyle: const TextStyle(
                                fontSize: 14,
                                color: Col.greyColor,
                                fontWeight: Fw.regular,
                              ),
                              lessStyle: const TextStyle(
                                fontSize: 12,
                                color: Col.greyColor,
                                fontWeight: Fw.regular,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (data.containsKey('addedByName'))
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Col.greenAccent.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.add_business,
                                color: Col.greenAccent,
                              ),
                            ),
                            title: Text(
                              'Ditambah oleh ${data['addedByName'] != null && data['addedByName'].length > 20 ? data['addedByName'].substring(0, 20) + '...' : data['addedByName'] ?? ''}',
                              style: Typo.emphasizedBodyTextStyle,
                            ),
                            subtitle: Text(
                              DateFormat('EEEE, dd MMMM y HH:mm', 'id')
                                  .format(createdAt.toDate()),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (data.containsKey('lastEditedByName'))
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Col.orangeAccent.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.edit_note,
                                color: Col.orangeAccent,
                              ),
                            ),
                            title: Text(
                              'Diupdate oleh ${data['lastEditedByName'] != null && data['addedByName'].length > 20 ? data['addedByName'].substring(0, 20) + '...' : data['addedByName'] ?? ''}',
                              style: Typo.emphasizedBodyTextStyle,
                            ),
                            subtitle: Text(
                              DateFormat('EEEE, dd MMMM y HH:mm', 'id')
                                  .format(updatedAt.toDate()),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
          );
        } else {
          return Scaffold(
            backgroundColor: Col.secondaryColor,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
            ),
            body: const Center(
              child: Text('Product not found.'),
            ),
          );
        }
      },
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Col.redAccent,
                shape: const CircleBorder(),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Produk'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus produk ini?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteProduct(widget.documentId);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Hapus'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete, color: Col.whiteColor, size: 20),
              tooltip: 'Hapus',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProdukPage(documentId: widget.documentId),
                    ),
                  );
                  setState(() {});
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note),
                    SizedBox(width: 8),
                    Text('Edit Produk'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 400,
            width: 400,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(.50),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
