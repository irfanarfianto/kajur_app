import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';

class EditStockPage extends StatefulWidget {
  final String documentId;
  final String namaProduk;
  final int stok;

  const EditStockPage({
    super.key,
    required this.documentId,
    required this.namaProduk,
    required this.stok,
  });

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

      AnimatedSnackBar.material(
        'Stok berhasil diperbarui',
        type: AnimatedSnackBarType.success,
      ).show(context);

      Navigator.pop(context);
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
              widget.namaProduk,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Stok Saat Ini: ${widget.stok}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.blackColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: DesignSystem.blackColor),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan Stok Baru',
                    hintStyle: TextStyle(
                      color: DesignSystem.greyColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int newStock =
                    int.tryParse(_stokController.text) ?? widget.stok;
                updateStock(newStock);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
