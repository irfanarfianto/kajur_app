import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/edit_products.dart';

class DetailProdukPage extends StatefulWidget {
  final String documentId;

  const DetailProdukPage({Key? key, required this.documentId})
      : super(key: key);

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  late CollectionReference _produkCollection;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
  }

  Future<void> _deleteProduct(String documentId) async {
    await _produkCollection.doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Produk'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
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
            padding: EdgeInsets.all(16),
            children: [
              Stack(
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${data['kategori']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['menu'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: DesignSystem.whiteColor,
                    ),
                  ),
                  Text(
                    'Rp ${data['harga']}',
                    style: TextStyle(
                      fontSize: 20,
                      color: DesignSystem.whiteColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Deskripsi:',
                style: TextStyle(
                  fontSize: 18,
                  color: DesignSystem.whiteColor,
                ),
              ),
              Text(
                '${data['deskripsi'] ?? 'Tidak ada deskripsi'}',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignSystem.whiteColor,
                ),
              ),
              if (data.containsKey('lastEditedByName'))
                Text(
                  'Terakhir diedit: ${data['lastEditedByName']}',
                  style: TextStyle(
                    color: DesignSystem.whiteColor,
                  ),
                ),
              if (data.containsKey('addedByName'))
                Text(
                  'Dibuat oleh: ${data['addedByName']}',
                  style: TextStyle(
                    color: DesignSystem.whiteColor,
                  ),
                ),
              SizedBox(height: 8),
              Text(
                'Created At: ${createdAt.toDate()}',
                style: TextStyle(
                  fontSize: 18,
                  color: DesignSystem.whiteColor,
                ),
              ),
              Text(
                'Updated At: ${updatedAt.toDate()}',
                style: TextStyle(
                  fontSize: 18,
                  color: DesignSystem.whiteColor,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: DesignSystem.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: DesignSystem.redAccent),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                            Navigator.pop(
                                context); // Kembali ke layar sebelumnya setelah menghapus
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
            SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: DesignSystem.purpleAccent,
                onPrimary: DesignSystem.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: DesignSystem.purpleAccent),
                ),
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
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
          ],
        ),
      ),
    );
  }
}
