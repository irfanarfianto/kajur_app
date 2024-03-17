import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:kajur_app/screens/products/tambah%20produk/details_add_product.dart';

class ProdukService {
  final CollectionReference _produkCollection =
      FirebaseFirestore.instance.collection('kantin');

  Stream<QuerySnapshot> get produkStream => _produkCollection.snapshots();

  Future<String?> getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userData['role'];
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return null;
  }

  Future<void> deleteProduct(String documentId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _produkCollection.doc(documentId).get();
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      await recordActivityLog(
        action: 'Hapus Produk',
        productId: documentId,
        productName: productData['menu'],
        productData: productData,
      );

      await _produkCollection.doc(documentId).delete();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> getProductCountByCategory(
      void Function(int totalProduk, int makananCount, int minumanCount)
          callback) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _produkCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      int totalProduk = 0;
      int makananCount = 0;
      int minumanCount = 0;

      snapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> document) {
        String? category = document.data()?['kategori'];
        if (category != null) {
          totalProduk++;
          if (category == 'Makanan') {
            makananCount++;
          } else if (category == 'Minuman') {
            minumanCount++;
          }
        }
      });

      callback(totalProduk, makananCount, minumanCount);
    } catch (error) {
      print("Error getting product count by category: $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
    try {
      final QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> userProfiles = [];

      userSnapshot.docs.forEach((userDoc) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('displayName') &&
            userData.containsKey('email') &&
            userData.containsKey('role')) {
          String displayName = userData['displayName'] ?? '';
          String email = userData['email'] ?? '';
          String role = userData['role'] ?? '';

          if (role == 'admin' || role == 'staf') {
            String photoUrl = userData['photoUrl'] ?? '';
            String whatsapp = userData['whatsapp'] ?? '';

            userProfiles.add({
              'displayName': displayName,
              'email': email,
              'photoUrl': photoUrl,
              'whatsapp': whatsapp,
              'role': role,
            });
          }
        }
      });

      return userProfiles;
    } catch (e) {
      print('Error getting user profiles: $e');
      return [];
    }
  }

  Future<String> uploadImage(File selectedImage) async {
    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      selectedImage.path,
      quality: 70,
    );
    File compressedFile = File(selectedImage.path)
      ..writeAsBytesSync(compressedImage!);

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('kantin')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(compressedFile);

    return await ref.getDownloadURL();
  }

  Future<void> addProduct({
    required String menu,
    required int hargaJual,
    required int hargaPokok,
    required int jumlahIsi,
    required String selectedCategory,
    required File selectedImage,
    required TextEditingController deskripsiController,
    required TextEditingController stokController,
    required GlobalKey<ScaffoldState> scaffoldKey,
    required BuildContext context,
  }) async {
    String imageUrl = await uploadImage(selectedImage);

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('kantin');

    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? userName = user?.displayName ?? 'Unknown User';

    int stok = int.tryParse(stokController.text) ?? 0;

    int totalProfit =
        ((hargaJual - (hargaPokok / jumlahIsi)) * jumlahIsi).toInt();
    int profitSatuan = (hargaJual - (hargaPokok / jumlahIsi)).toInt();

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
    });

    await recordActivityLog(
      action: 'Tambah Produk',
      productName: menu,
      productId: docRef.id,
      productData: {
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
        'createdAt': DateTime.now(),
        'addedBy': userId,
        'addedByName': userName,
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      },
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductDetailPage(
          addedByName: userName,
          productName: menu,
          hargaJual: hargaJual,
          hargaPokok: hargaPokok,
          jumlahIsi: jumlahIsi,
          kategori: selectedCategory,
          imageUrl: imageUrl,
          deskripsi: deskripsiController.text,
          stok: stok,
          totalProfit: totalProfit,
          profitSatuan: profitSatuan,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> recordActivityLog({
    required String action,
    required String productName,
    required String productId,
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
}
