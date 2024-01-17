import 'dart:io';
import 'dart:typed_data';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kajur_app/design/system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  bool isInfoSnackbarVisible = false;

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

  Future<String> _uploadImage() async {
    if (_selectedImage == null) return '';

    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      _selectedImage!.path,
      quality: 70,
    );
    File compressedFile = File(_selectedImage!.path)
      ..writeAsBytesSync(compressedImage!);

    Reference ref = FirebaseStorage.instance
        .ref()
        .child('kantin')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(compressedFile);

    return await ref.getDownloadURL();
  }

  Future<void> _submitData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String menu = _menuController.text;
    String hargaText = _hargaController.text;
    String stokText = _stokController.text;
    int harga = int.tryParse(hargaText) ?? 0;
    int stok = int.tryParse(stokText) ?? 0;

    // Validasi input
    if (menu.isNotEmpty &&
        harga > 0 &&
        stok >= 0 &&
        _selectedCategory.isNotEmpty &&
        _selectedImage != null &&
        hargaText == harga.toString() &&
        stokText == stok.toString()) {
      // Lanjutkan dengan upload gambar
      String imageUrl = await _uploadImage();

      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('kantin');

      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;
      String? userName = user?.displayName ?? 'Unknown User';

      // Tambahkan data produk
      DocumentReference docRef = await collectionRef.add({
        'menu': menu,
        'harga': harga,
        'kategori': _selectedCategory,
        'image': imageUrl,
        'deskripsi': _deskripsiController.text,
        'stok': stok,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'addedBy': userId,
        'addedByName': userName,
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      });

      // Tambahkan log aktivitas
      await _recordActivityLog(
        action: 'Tambah Produk',
        productName: menu, // Add product name to activity log
        productId: docRef.id, // Add product ID to activity log
      );

      AnimatedSnackBar.material(
        'Produk berhasil ditambahkan',
        type: AnimatedSnackBarType.success,
      ).show(context);

      Navigator.pushReplacementNamed(context, '/list_produk');
    } else {
      if (!isInfoSnackbarVisible) {
        AnimatedSnackBar.material(
          'Mohon isi semua field yang diperlukan dan pastikan harga dan stok valid',
          type: AnimatedSnackBarType.info,
        ).show(context);

        isInfoSnackbarVisible = true;

        // Setelah beberapa detik, reset kembali variabel untuk memungkinkan snackbar muncul lagi
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            isInfoSnackbarVisible = false;
          });
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _recordActivityLog({
    required String action,
    required String productName,
    required String productId,
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
      'productName': productName, // Add product name to activity log
      'productId': productId, // Add product ID to activity log
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text('Tambah Produk'),
      ),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DesignSystem.greyColor.withOpacity(.50),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(),
                      GestureDetector(
                        onTap: () {
                          // Menampilkan dialog pilihan untuk mengambil gambar dari kamera atau galeri
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Pilih Sumber Gambar"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _getImage(ImageSource
                                          .gallery); // Ambil gambar dari galeri
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                            Icons.photo_library), // Icon galeri
                                        SizedBox(
                                            width:
                                                8), // Spasi antara icon dan teks
                                        Text("Galeri"), // Teks pilihan galeri
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _getImage(ImageSource
                                          .camera); // Ambil gambar dari kamera
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.camera_alt), // Icon kamera
                                        SizedBox(
                                            width:
                                                8), // Spasi antara icon dan teks
                                        Text("Kamera"), // Teks pilihan kamera
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: DesignSystem.greyColor
                                            .withOpacity(.20),
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
                      ),
                    ],
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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Pilih kategori *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    hint: Text(
                      'Pilih kategori',
                      style: TextStyle(
                        color: DesignSystem.greyColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    value:
                        _selectedCategory.isNotEmpty ? _selectedCategory : null,
                    style: TextStyle(color: DesignSystem.greyColor),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Makanan',
                        child: Text(
                          'Makanan',
                          style: TextStyle(
                              color: DesignSystem.blackColor, fontSize: 16),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Minuman',
                        child: Text(
                          'Minuman',
                          style: TextStyle(
                              color: DesignSystem.blackColor, fontSize: 16),
                        ),
                      ),
                    ],
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: DesignSystem.backgroundColor,
                          border: Border.all(
                            color: DesignSystem.greyColor.withOpacity(.20),
                          )),
                    ),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(right: 8),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.expand_more_outlined,
                        color: Colors.black45,
                      ),
                      iconSize: 24,
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value ?? '';
                      });
                    },
                  ),
                ]),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deskripsi *',
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
                  onPressed: _isLoading ? null : () => _submitData(context),
                  child: Container(
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : Text(
                              "Tambah",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
