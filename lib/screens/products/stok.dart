import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStockPage extends StatefulWidget {
  final String documentId;
  final String namaProduk;
  final int stok;

  const EditStockPage({
    Key? key,
    required this.documentId,
    required this.namaProduk,
    required this.stok,
  }) : super(key: key);

  @override
  _EditStockPageState createState() => _EditStockPageState();
}

class _EditStockPageState extends State<EditStockPage> {
  late TextEditingController _stokController;

  @override
  void initState() {
    super.initState();
    _stokController = TextEditingController(text: widget.stok.toString());
  }

  @override
  void dispose() {
    _stokController.dispose();
    super.dispose();
  }

  Future<void> updateStock(int newStock) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';
      String userName =
          FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown';

      await FirebaseFirestore.instance
          .collection('kantin')
          .doc(widget.documentId)
          .update({
        'stok': newStock,
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      });

      // Jika diperlukan, tambahkan logika lain setelah pembaruan berhasil
      // Contoh: menampilkan pesan sukses atau navigasi kembali ke layar sebelumnya
      // dengan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok berhasil diperbarui'),
        ),
      );
    } catch (error) {
      // Handle error
      print('Error updating stock: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Stok - ${widget.namaProduk}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Produk: ${widget.namaProduk}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Stok Saat Ini: ${widget.stok}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _stokController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edit Stok Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int newStock =
                    int.tryParse(_stokController.text) ?? widget.stok;
                updateStock(newStock);
                Navigator.of(context).pop();
              },
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
