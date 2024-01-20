import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';

class EditStokPage extends StatefulWidget {
  final int initialStock; // Tambahkan properti untuk menyimpan stok awal

  EditStokPage({required this.initialStock});

  @override
  _EditStokPageState createState() => _EditStokPageState();
}

class _EditStokPageState extends State<EditStokPage> {
  int _newStock = 0;

  @override
  void initState() {
    super.initState();
    _newStock = widget.initialStock; // Set stok awal saat halaman dimulai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Stok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Sebelum Diperbarui: ${widget.initialStock}',
              style: DesignSystem.subtitleTextStyle,
            ),
            SizedBox(height: 16),
            Text(
              'Masukkan Jumlah Stok Baru',
              style: DesignSystem.titleTextStyle,
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Stok Baru',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _newStock = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateStock();
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStock() {
    // Implement logic to update the stock in Firestore or any other backend
    showToast(message: 'Stok berhasil diperbarui');
    Navigator.pop(context,
        _newStock); // Return the new stock value to the previous screen
  }
}
