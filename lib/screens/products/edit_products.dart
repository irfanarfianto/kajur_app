import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';

class EditProdukPage extends StatefulWidget {
  final String documentId;

  const EditProdukPage({Key? key, required this.documentId}) : super(key: key);

  @override
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _menuController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _stokController;

  late CollectionReference _produkCollection;
  File? _selectedImage;
  String? _oldImageUrl;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _oldImageUrl = '';
    _menuController = TextEditingController();
    _hargaController = TextEditingController();
    _deskripsiController = TextEditingController();
    _stokController = TextEditingController();

    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _produkCollection.doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        _menuController.text = data['menu'];
        _hargaController.text = data['harga'].toString();
        _deskripsiController.text = data['deskripsi'];
        _stokController.text = data['stok']?.toString() ?? '0';

        setState(() {
          _oldImageUrl = data['image'];
        });
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _updateProductDetails() async {
    try {
      if (_menuController.text.isEmpty ||
          _hargaController.text.isEmpty ||
          _stokController.text.isEmpty) {
        AnimatedSnackBar.material(
          'Eitss! Jangan ada kolom yang kosong ya',
          type: AnimatedSnackBarType.info,
        ).show(context);
        return;
      }

      String hargaText = _hargaController.text;
      String stokText = _stokController.text;
      int harga = int.tryParse(hargaText) ?? 0;
      int stok = int.tryParse(stokText) ?? 0;

      // Validasi input
      if (hargaText == harga.toString() && stokText == stok.toString()) {
        User? user = FirebaseAuth.instance.currentUser;
        String? userId = user?.uid;
        String? userName = user?.displayName ?? 'Unknown User';

        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImage();
        } else {
          imageUrl =
              _oldImageUrl; // Gunakan gambar lama jika tidak ada gambar baru dipilih
        }

        // Mendapatkan detail produk sebelum diperbarui
        DocumentSnapshot oldProductSnapshot =
            await _produkCollection.doc(widget.documentId).get();
        Map<String, dynamic> oldProductData =
            oldProductSnapshot.data() as Map<String, dynamic>;

        // Merekam log aktivitas
        await _recordActivityLog(
          action: 'Edit Produk',
          oldProductData: oldProductData,
          productName: _menuController.text,
          newProductData: {
            'menu': _menuController.text,
            'harga': harga,
            'deskripsi': _deskripsiController.text,
            'image': imageUrl,
            'stok': stok,
          },
        );

        await _produkCollection.doc(widget.documentId).update({
          'menu': _menuController.text,
          'harga': harga,
          'deskripsi': _deskripsiController.text,
          'image': imageUrl,
          'stok': stok,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastEditedBy': userId,
          'lastEditedByName': userName,
        });
        AnimatedSnackBar.material(
          'Produk berhasil diperbarui',
          type: AnimatedSnackBarType.success,
        ).show(context);
        Navigator.pop(context);
      } else {
        AnimatedSnackBar.material(
          'Mohon isi harga dan stok dengan angka',
          type: AnimatedSnackBarType.info,
        ).show(context);
      }
    } catch (e) {
      print('Error updating product details: $e');
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required Map<String, dynamic> oldProductData,
    required Map<String, dynamic> newProductData,
    required String productName,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;
    String? userName = user?.displayName ?? 'Unknown User';

    // Membuat referensi ke koleksi log aktivitas
    CollectionReference activityLogCollection =
        FirebaseFirestore.instance.collection('activity_log');

    // Merekam log aktivitas ke koleksi
    await activityLogCollection.add({
      'userId': userId,
      'userName': userName,
      'action': action,
      'productName': productName,
      'oldProductData': oldProductData,
      'newProductData': newProductData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('kantin')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(_selectedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Edit Produk'),
      ),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Pilih Sumber Gambar"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _getImage(ImageSource.gallery);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.photo_library),
                                  SizedBox(width: 8),
                                  Text("Galeri"),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _getImage(ImageSource.camera);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text("Kamera"),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: DesignSystem.greyColor.withOpacity(.20),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_oldImageUrl != null && _oldImageUrl != '')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  _oldImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(Icons.add_a_photo),
                              ),
                  ),
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Produk *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.blackColor,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: _menuController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: DesignSystem.blackColor),
                      decoration: InputDecoration(
                        hintText: 'Nama produk',
                        hintStyle: TextStyle(
                          color: DesignSystem.greyColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.blackColor,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            style: TextStyle(color: DesignSystem.blackColor),
                            controller: _hargaController,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: Text('Rp',
                                      style: TextStyle(
                                        color: DesignSystem.greyColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ))),
                              hintText: 'Harga',
                              hintStyle: TextStyle(
                                color: DesignSystem.greyColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stok *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.blackColor,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            controller: _stokController,
                            style: TextStyle(color: DesignSystem.blackColor),
                            decoration: InputDecoration(
                              hintText: 'Stok',
                              hintStyle: TextStyle(
                                color: DesignSystem.greyColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.blackColor,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(
                        hintText: 'Masukan deskripsi produk',
                        hintStyle: TextStyle(
                          color: DesignSystem.greyColor,
                          fontWeight: FontWeight.normal,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      style: TextStyle(color: DesignSystem.blackColor),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    _updateProductDetails();
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}
