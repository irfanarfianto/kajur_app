import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:kajur_app/screens/products/edit_products.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailProdukPage extends StatefulWidget {
  final String documentId;

  const DetailProdukPage({super.key, required this.documentId});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  late CollectionReference _produkCollection;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _refreshData();
  }

  void _deleteProduct(String documentId) async {
    try {
      // Mendapatkan detail produk sebelum dihapus
      DocumentSnapshot productSnapshot =
          await _produkCollection.doc(documentId).get();
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      // Merekam log aktivitas
      await _recordActivityLog(
        action: 'Hapus Produk',
        productName: productData['menu'],
        productData: productData,
      );

      // Menghapus produk dari Firestore
      await _produkCollection.doc(documentId).delete();
      showToast(message: 'Produk berhasil dihapus');
    } catch (e) {
      print('Error: $e');
      showToast(message: 'Terjadi kesalahan saat menghapus produk');
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required String productName,
    required Map<String, dynamic> productData,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? userName = user?.displayName ?? 'Unknown User';

    CollectionReference activityLogCollection =
        FirebaseFirestore.instance.collection('activity_log');

    await activityLogCollection.add({
      'userId': userId,
      'userName': userName,
      'action': action,
      'productName': productName,
      'productData': productData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) {
      return; // Check if the widget is still mounted
    }

    // Set state to indicate refreshing
    setState(() {
      _enabled = true;
    });

    try {
      // Fetch or refresh data here (e.g., refetch Firestore data)
      await Future.delayed(const Duration(seconds: 1)); // Simulating a delay
    } catch (error) {
      // Handle error in case of any issues during refresh
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

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        backgroundColor: DesignSystem.secondaryColor,
        appBar: AppBar(
          title: const Text('Detail Produk'),
        ),
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(child: _buildProductDetails())),
        bottomNavigationBar: _buildBottomAppBar(),
      ),
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
        var data = documents
            .firstWhere((doc) => doc.id == widget.documentId)
            .data() as Map<String, dynamic>;

        Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
        Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

        return Skeletonizer(
          enabled: _enabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageDialog(context, data['image']);
                },
                child: Skeleton.leaf(
                  child: Hero(
                    tag: 'product_image_${widget.documentId}',
                    child: SizedBox(
                      height: 350,
                      width: double.infinity,
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            data['menu'],
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: DesignSystem.blackColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Skeleton.leaf(
                              child: StatusBadge(
                                label: data['kategori'] == 'Makanan'
                                    ? 'Makanan'
                                    : data['kategori'] == 'Minuman'
                                        ? 'Minuman'
                                        : 'Kategori Tidak Diketahui',
                                color: data['kategori'] == 'Makanan'
                                    ? Colors.green
                                    : data['kategori'] == 'Minuman'
                                        ? DesignSystem.primaryColor
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Skeleton.leaf(
                              child: StatusBadge(
                                label: data['stok'] == 0
                                    ? 'Stok habis'
                                    : 'Stok ${data['stok'] ?? 0}',
                                color: data['stok'] == 0
                                    ? DesignSystem.redAccent
                                    : data['stok'] < 5
                                        ? DesignSystem.primaryColor
                                        : DesignSystem.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(data['harga']),
                      style: const TextStyle(
                        fontSize: 20,
                        color: DesignSystem.blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deskripsi produk',
                            style: DesignSystem.subtitleTextStyle),
                        ReadMoreText(
                            '${data['deskripsi'] ?? 'Tidak ada deskripsi'}',
                            trimLines: 3,
                            style: DesignSystem.bodyTextStyle,
                            colorClickableText: DesignSystem.primaryColor,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Baca selengkapnya',
                            trimExpandedText: 'Tutup',
                            moreStyle: const TextStyle(
                              fontSize: 14,
                              color: DesignSystem.greyColor,
                              fontWeight: DesignSystem.regular,
                            ),
                            lessStyle: const TextStyle(
                              fontSize: 12,
                              color: DesignSystem.greyColor,
                              fontWeight: DesignSystem.regular,
                            )),
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
                            color: Colors.green.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.green,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ditambah oleh ${data['addedByName']}',
                                style: DesignSystem.emphasizedBodyTextStyle),
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const AllActivitiesPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.east,
                                color: DesignSystem.greyColor,
                                size: 18,
                              ),
                            )
                          ],
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
                            color: Colors.orange.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          'Diupdate oleh ${data['lastEditedByName']}',
                          style: DesignSystem.emphasizedBodyTextStyle,
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
            ],
          ),
        );
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
                backgroundColor: DesignSystem.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: DesignSystem.redAccent),
                ),
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
              icon: const Icon(Icons.delete,
                  color: DesignSystem.whiteColor, size: 20),
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
                child: const Text('Edit'),
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

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

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
          fontSize: 10,
          color: Colors.white,
        ),
      ),
    );
  }
}
