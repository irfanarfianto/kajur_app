import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kajur_app/utils/global/common/toast.dart';

class AddProductService {
  final TextEditingController kodeBarangController = TextEditingController();
  final TextEditingController menuController = TextEditingController();
  final TextEditingController hargaJualController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController hargaPokokController = TextEditingController();
  final TextEditingController jumlahIsiController = TextEditingController();
  String selectedCategory = '';
  String kodeBarang = '';
  File? selectedImage;

  Future<void> getImage(ImageSource source, Function(File) setImage) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  Future<void> scanBarcode(BuildContext context) async {
    try {
      String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Batal', true, ScanMode.BARCODE);

      if (barcodeResult != '-1') {
        kodeBarang = barcodeResult; // Simpan data barcode
        kodeBarangController.text = barcodeResult;
      }
    } on PlatformException {
      // Handle platform exception
    }
  }

  Future<String> uploadImage(File? imageFile) async {
    if (imageFile == null) return '';

    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 70,
    );
    File compressedFile = File(imageFile.path)
      ..writeAsBytesSync(compressedImage!);

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('kantin')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(compressedFile);

    return await ref.getDownloadURL();
  }

  Future<void> submitData(
      BuildContext context, Function(bool) setLoading) async {
    setLoading(true);

    try {
      String menu = menuController.text;
      String hargaJualText = hargaJualController.text;
      String stokText = stokController.text;
      String hargaPokokText = hargaPokokController.text;
      String jumlahIsiText = jumlahIsiController.text;

      int hargaJual =
          int.tryParse(hargaJualText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int stok = int.tryParse(stokText) ?? 0;
      int hargaPokok =
          int.tryParse(hargaPokokText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      int jumlahIsi = int.tryParse(jumlahIsiText) ?? 0;

      // Pengecekan jika semua data telah diisi
      if (menu.isNotEmpty &&
          hargaJual > 0 &&
          stok >= 0 &&
          hargaPokok > 0 &&
          jumlahIsi > 0 &&
          selectedCategory.isNotEmpty &&
          selectedImage != null &&
          stokText == stok.toString() &&
          jumlahIsiText == jumlahIsi.toString()) {
        // Pengecekan apakah kode barang sudah ada sebelumnya
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('kantin')
            .where('kodeBarang', isEqualTo: kodeBarang)
            .get();

        if (querySnapshot.docs.isEmpty) {
          int totalProfit =
              ((hargaJual - (hargaPokok / jumlahIsi)) * jumlahIsi).toInt();
          int profitSatuan = (hargaJual - (hargaPokok / jumlahIsi)).toInt();

          String imageUrl = await uploadImage(selectedImage);

          CollectionReference collectionRef =
              FirebaseFirestore.instance.collection('kantin');

          User? user = FirebaseAuth.instance.currentUser;
          String? userId = user?.uid;
          String? userName = user?.displayName ?? 'Unknown User';

          DocumentReference docRef = await collectionRef.add({
            'menu': menu,
            'hargaJual': hargaJual,
            'hargaPokok': hargaPokok,
            'jumlahIsi': jumlahIsi,
            'kategori': selectedCategory,
            'image': imageUrl,
            'deskripsi': deskripsiController.text,
            'stok': stok,
            'totalProfit': totalProfit,
            'profitSatuan': profitSatuan,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'addedBy': userId,
            'addedByName': userName,
            'lastEditedBy': userId,
            'lastEditedByName': userName,
            'kodeBarang': kodeBarang,
          });

          await recordActivityLog(
            action: 'Tambah Produk',
            productName: menu,
            productId: docRef.id,
          );

          showToast(message: 'Produk berhasil ditambahkan');
          Navigator.of(context).pop();
          setLoading(false);
        } else {
          setLoading(false);
          showToast(message: 'Kode barang sudah ada');
        }
      } else {
        setLoading(false);
        showToast(message: 'Produk gagal ditambahkan');
      }
    } catch (error) {
      showToast(message: 'Produk gagal ditambahkan');
      setLoading(false);
    }
  }

  Future<void> recordActivityLog({
    required String action,
    required String productName,
    required String productId,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? userName = user?.displayName ?? 'Unknown User';

    CollectionReference activityLogCollection =
        FirebaseFirestore.instance.collection('activity_log');

    await activityLogCollection.add({
      'userId': userId,
      'kodeBarang': kodeBarang,
      'userName': userName,
      'action': action,
      'productName': productName,
      'productId': productId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
