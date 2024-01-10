import 'dart:io';

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

      await _produkCollection.doc(widget.documentId).update({
        'menu': _menuController.text,
        'harga': int.tryParse(_hargaController.text) ?? 0,
        'deskripsi': _deskripsiController.text,
        'image': imageUrl,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      });
      showToast(message: 'Produk berhasil diperbarui');
      Navigator.pop(context);
    } catch (e) {
      print('Error updating product details: $e');
    }
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
        title: Text('Edit Produk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  height: 150,
                  width: 150,
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
              TextFormField(
                controller: _menuController,
                style: TextStyle(color: DesignSystem.whiteColor),
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  hintStyle: TextStyle(color: DesignSystem.greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _hargaController,
                      style: TextStyle(color: DesignSystem.whiteColor),
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        hintStyle: TextStyle(color: DesignSystem.greyColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _stokController,
                      style: TextStyle(color: DesignSystem.whiteColor),
                      decoration: InputDecoration(
                        labelText: 'Stok',
                        hintStyle: TextStyle(color: DesignSystem.greyColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _deskripsiController,
                style: TextStyle(color: DesignSystem.whiteColor),
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintStyle: TextStyle(color: DesignSystem.greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
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
