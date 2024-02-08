import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:share_plus/share_plus.dart';

class ShareProduk extends StatefulWidget {
  const ShareProduk({super.key});

  @override
  ShareProdukState createState() => ShareProdukState();
}

class ShareProdukState extends State<ShareProduk> {
  String text = '';
  String subject = '';
  String userId = FirebaseAuth.instance.currentUser!.uid;
  double _sliderValue = 5; // Nilai default slider

  Future<void> _getDataFromFirestore() async {
    try {
      CollectionReference produkCollection =
          FirebaseFirestore.instance.collection('kantin');
      // Mengambil data produk dengan stok di bawah nilai slider
      QuerySnapshot querySnapshot =
          await produkCollection.where('stok', isLessThan: _sliderValue).get();

      // Mengecek apakah ada produk dengan stok di bawah nilai slider
      if (querySnapshot.docs.isNotEmpty) {
        int totalHargaPokok = 0; // Inisialisasi total harga pokok

        String textData = '';

        // Mendapatkan informasi pengguna yang sedang login sekali
        User? user = FirebaseAuth.instance.currentUser;
        String senderName = user != null
            ? user.displayName ?? user.email ?? 'Unknown User'
            : 'Unknown User';

        // Format waktu saat ini sekali
        String formattedDate = DateFormat('EEEE, dd MMMM y - HH:mm:ss', 'id')
            .format(DateTime.now());

        // Menambahkan informasi pengguna dan waktu sekali
        textData += 'Pengirim: $senderName\n'
            '$formattedDate\n\n';

        for (var document in querySnapshot.docs) {
          String menu = document['menu'];
          int hargaPokok = document['hargaPokok'] ?? 0;
          int qty = document['stok'] ?? 0;

          // Menambahkan garis pembatas setelah setiap produk
          textData += '---------------------------\n'
              'Nama produk: $menu\n'
              'Harga pokok: ${_formatCurrency(hargaPokok)}\n' // Format uang ke Rupiah
              'Sisa stok: ${qty > 0 ? qty : "Stok Habis"}\n';

          // Menambahkan harga pokok ke total
          totalHargaPokok += hargaPokok;
        }

        // Menambahkan keterangan total harga pokok
        textData +=
            '---------------------------\nPerkiraan uang yang harus\ndibayar: ${_formatCurrency(totalHargaPokok)}\n\n\n'
            'Pengurus Kantin Kejujuran 2024 🙌';

        setState(() {
          text = textData;
        });
      } else {
        setState(() {
          text = 'Tidak ada produk dengan stok di bawah $_sliderValue';
        });
      }
    } catch (e) {
      print("Error: $e");
      // Handle error jika diperlukan
    }
  }

  String _formatCurrency(int amount) {
    NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Col.primaryColor,
          foregroundColor: Col.whiteColor,
          title: const Text('Kirim Data Produk'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Batasi stok < ${_sliderValue.toInt()}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _sliderValue.toDouble(),
                min: 0,
                max: 15,
                divisions: 15,
                label: _sliderValue.toInt().toString(),
                onChanged: (newValue) {
                  setState(() {
                    _sliderValue = newValue;
                  });
                },
              ),
              FutureBuilder(
                future: _getDataFromFirestore(),
                builder: (context, snapshot) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            icon: const Icon(Icons.send),
            onPressed: text.isEmpty ? null : () => _onShare(context),
            label: const Row(
              children: [
                Text('Kirim'),
              ],
            )),
      ),
    );
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(text,
        subject: subject,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }
}
