import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kajur_app/design/system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  String _selectedCategory = '';
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<String> _uploadImage() async {
    if (_selectedImage == null) return '';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('kantin')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(_selectedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _submitData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String menu = _menuController.text;
    int harga = int.tryParse(_hargaController.text) ?? 0;
    int stok = int.tryParse(_stokController.text) ??
        0; // Ambil nilai stok dari TextFormField

    if (menu.isNotEmpty &&
        harga > 0 &&
        stok >= 0 && // Pastikan stok tidak negatif
        _selectedCategory.isNotEmpty &&
        _selectedImage != null) {
      String imageUrl = await _uploadImage();

      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('kantin');

      // Get current user ID and name
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;
      String? userName = user?.displayName ?? 'Unknown User';

      await collectionRef.add({
        'menu': menu,
        'harga': harga,
        'kategori': _selectedCategory,
        'image': imageUrl,
        'deskripsi': _deskripsiController.text,
        'stok': stok, // Simpan nilai stok ke dalam database
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'addedBy': userId,
        'addedByName': userName,
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Data berhasil ditambahkan'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/list_produk');
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $error'),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Mohon isi semua bidang',
          ),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                // margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DesignSystem.greyColor.withOpacity(.50),
                  ),
                ),
                child: Stack(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(),
                    GestureDetector(
                      onTap: () => _getImage(),
                      child: Center(
                        child: _selectedImage != null
                            ? Container()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: DesignSystem.greyColor,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload Foto',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: DesignSystem.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _menuController,
                      style: TextStyle(color: DesignSystem.whiteColor),
                      decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        hintStyle: TextStyle(color: DesignSystem.greyColor),
                      ),
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
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(color: DesignSystem.whiteColor),
                      controller: _hargaController,
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        hintStyle: TextStyle(color: DesignSystem.greyColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: DesignSystem.whiteColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCategory.isNotEmpty
                          ? _selectedCategory
                          : null,
                      style: TextStyle(color: DesignSystem.greyColor),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        filled: true, // Aktifkan pengisian background
                        fillColor: DesignSystem
                            .blackColor, // Atur warna latar belakang di sini
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: DesignSystem.whiteColor),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Makanan',
                          child: Text(
                            'Makanan',
                            style: TextStyle(color: DesignSystem.whiteColor),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Minuman',
                          child: Text(
                            'Minuman',
                            style: TextStyle(color: DesignSystem.whiteColor),
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value ?? '';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: DesignSystem.whiteColor),
                  ),
                ),
                style: TextStyle(color: DesignSystem.whiteColor),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
              SizedBox(height: 24.0),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoading ? null : () => _submitData(context),
                      child: Text('Tambah Data'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
