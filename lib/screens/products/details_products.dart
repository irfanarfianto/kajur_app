import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/products/edit_products.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailProdukPage extends StatefulWidget {
  final String documentId;

  const DetailProdukPage({Key? key, required this.documentId})
      : super(key: key);

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
      await Future.delayed(Duration(seconds: 1)); // Simulating a delay
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Detail Produk'),
      ),
      body: _buildProductDetails(),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildProductDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: _produkCollection.snapshots(), // Use snapshots() to get a stream
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        var documents = snapshot.data!.docs;
        var data = documents
            .firstWhere((doc) => doc.id == widget.documentId)
            .data() as Map<String, dynamic>;

        Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
        Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                _showImageDialog(context, data['image']);
              },
              child: Hero(
                tag: 'product_image_${widget.documentId}',
                child: GestureDetector(
                  onTap: () {
                    _showImageDialog(context, data['image']);
                  },
                  child: Skeleton.keep(
                    child: Container(
                      height: 350,
                      width: double.infinity,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: data['image'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Skeletonizer(
                enabled: _enabled,
                child: Container(
                  padding: EdgeInsets.all(16),
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
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                color: DesignSystem.blackColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Row(children: [
                            Skeleton.leaf(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: data['kategori'] == 'Makanan'
                                      ? Colors.green.withOpacity(.50)
                                      : data['kategori'] == 'Minuman'
                                          ? DesignSystem.primaryColor
                                              .withOpacity(.50)
                                          : Colors.grey,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  data['kategori'] == 'Makanan'
                                      ? 'Makanan'
                                      : data['kategori'] == 'Minuman'
                                          ? 'Minuman'
                                          : 'Kategori Tidak Diketahui',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DesignSystem.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Skeleton.leaf(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: data['stok'] == 0
                                      ? DesignSystem.redAccent.withOpacity(.50)
                                      : data['stok'] < 5
                                          ? DesignSystem.primaryColor
                                              .withOpacity(.50)
                                          : DesignSystem.primaryColor
                                              .withOpacity(.50),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  data['stok'] == 0
                                      ? 'Stok habis'
                                      : 'Stok ${data['stok'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DesignSystem.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                      Text(
                        NumberFormat.currency(
                                locale: 'id', symbol: 'Rp', decimalDigits: 0)
                            .format(data['harga']),
                        style: TextStyle(
                          fontSize: 20,
                          color: DesignSystem.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (data.containsKey('addedByName'))
                        Text(
                          'Dibuat oleh ${data['addedByName']}, ${DateFormat('EEEE, dd MMMM y HH:mm', 'id').format(createdAt.toDate())}',
                          style: TextStyle(
                            color: DesignSystem.blackColor,
                          ),
                        ),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi produk',
                            style: TextStyle(
                              fontSize: 18,
                              color: DesignSystem.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ReadMoreText(
                            '${data['deskripsi'] ?? 'Tidak ada deskripsi'}',
                            trimLines: 2,
                            colorClickableText: DesignSystem.primaryColor,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Baca selengkapnya',
                            trimExpandedText: 'Tutup',
                            moreStyle: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (data.containsKey('lastEditedByName'))
                        Text(
                          'Diupdate pada ${DateFormat('EEEE, dd MMMM y HH:mm', 'id').format(updatedAt.toDate())}, oleh ${data['lastEditedByName']}',
                          style: TextStyle(
                            color: DesignSystem.blackColor,
                          ),
                        ),
                    ],
                  ),
                )),
          ],
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
                  side: BorderSide(color: DesignSystem.redAccent),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Hapus Produk'),
                      content:
                          Text('Apakah Anda yakin ingin menghapus produk ini?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteProduct(widget.documentId);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Hapus'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon:
                  Icon(Icons.delete, color: DesignSystem.whiteColor, size: 20),
              tooltip: 'Hapus',
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
                child: Text('Edit'),
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
          child: Container(
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
