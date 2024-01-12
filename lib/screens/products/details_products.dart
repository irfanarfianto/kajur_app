import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/products/edit_products.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class DetailProdukPage extends StatefulWidget {
  final String documentId;

  const DetailProdukPage({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  late CollectionReference _produkCollection;
  late Future<DocumentSnapshot> _productFuture;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _productFuture = _fetchProductData();
  }

  Future<DocumentSnapshot> _fetchProductData() async {
    return await FirebaseFirestore.instance
        .collection('kantin')
        .doc(widget.documentId)
        .get();
  }

  void _deleteProduct(String documentId) async {
    try {
      await _produkCollection.doc(documentId).delete();
      showToast(message: 'Produk berhasil dihapus');
    } catch (e) {
      print('Error: $e');
      showToast(message: 'Terjadi kesalahan saat menghapus produk');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Detail Produk'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _productFuture = _fetchProductData();
          });
        },
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('kantin')
              .doc(widget.documentId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Document does not exist'));
            }

            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            Timestamp createdAt = data['createdAt'] ?? Timestamp.now();
            Timestamp updatedAt = data['updatedAt'] ?? Timestamp.now();

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                GestureDetector(
                  onTap: () {
                    _showImageDialog(context, data['image']);
                  },
                  child: Hero(
                    tag: 'product_image_${widget.documentId}',
                    child: Container(
                      height: 350,
                      width: double.infinity,
                      child: ClipRRect(
                        child: Image.network(
                          data['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
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
                            Container(
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
                            SizedBox(width: 8),
                            Container(
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
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
                        content: Text(
                            'Apakah Anda yakin ingin menghapus produk ini?'),
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
                icon: Icon(Icons.delete,
                    color: DesignSystem.whiteColor, size: 20),
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
