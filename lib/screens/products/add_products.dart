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
import 'package:kajur_app/screens/products/tambah%20produk/details_add_product.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _hargaPokokController = TextEditingController();
  final TextEditingController _jumlahIsiController = TextEditingController();
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
    String hargaJualText = _hargaJualController.text;
    String stokText = _stokController.text;
    String hargaPokokText = _hargaPokokController.text;
    String jumlahIsiText = _jumlahIsiController.text;

    int hargaJual = int.tryParse(hargaJualText) ?? 0;
    int stok = int.tryParse(stokText) ?? 0;
    int hargaPokok = int.tryParse(hargaPokokText) ?? 0;
    int jumlahIsi = int.tryParse(jumlahIsiText) ?? 0;

    // Validasi input
    if (menu.isNotEmpty &&
        hargaJual > 0 &&
        stok >= 0 &&
        hargaPokok > 0 && // Validasi harga pokok
        jumlahIsi > 0 && // Validasi jumlah isi
        _selectedCategory.isNotEmpty &&
        _selectedImage != null &&
        hargaJualText == hargaJual.toString() &&
        stokText == stok.toString() &&
        hargaPokokText == hargaPokok.toString() &&
        jumlahIsiText == jumlahIsi.toString()) {
      // Hitung keuntungan per produk
      int totalProfit =
          ((hargaJual - (hargaPokok / jumlahIsi)) * jumlahIsi).toInt();
      int profitSatuan = (hargaJual - (hargaPokok / jumlahIsi)).toInt();

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
        'hargaJual': hargaJual,
        'hargaPokok': hargaPokok,
        'jumlahIsi': jumlahIsi,
        'kategori': _selectedCategory,
        'image': imageUrl,
        'deskripsi': _deskripsiController.text,
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

      // Tambahkan log aktivitas
      await _recordActivityLog(
        action: 'Tambah Produk',
        productName: menu,
        productId: docRef.id,
      );

      // // ignore: use_build_context_synchronously
      // AnimatedSnackBar.material(
      //   'Produk berhasil ditambahkan',
      //   type: AnimatedSnackBarType.success,
      // ).show(context);

      // Tampilkan keuntungan
      // print('Keuntungan per produk(jika laku total): Rp $totalProfit');
      // print('Keuntungan per produk(satuan): Rp $profitSatuan');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddProductDetailPage(
            addedByName: userName,
            productName: menu,
            hargaJual: hargaJual,
            hargaPokok: hargaPokok,
            jumlahIsi: jumlahIsi,
            kategori: _selectedCategory,
            imageUrl: imageUrl,
            deskripsi: _deskripsiController.text,
            stok: stok,
            totalProfit: totalProfit,
            profitSatuan: profitSatuan,
            createdAt: DateTime.now(),
          ),
        ),
      );
    } else {
      AnimatedSnackBar.material(
        'Mohon isi semua field yang diperlukan dan pastikan harga dan stok valid',
        type: AnimatedSnackBarType.info,
      ).show(context);

      // Setelah beberapa detik, reset kembali variabel untuk memungkinkan snackbar muncul lagi
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
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
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Tambah Produk'),
      ),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10),
            physics: const BouncingScrollPhysics(),
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
                                title: const Text("Pilih Sumber Gambar",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: DesignSystem.blackColor,
                                      fontSize: 16,
                                    )),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _getImage(ImageSource
                                          .gallery); // Ambil gambar dari galeri
                                    },
                                    child: const Row(
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
                                    child: const Row(
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
                          padding: const EdgeInsets.all(10),
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
                                      const SizedBox(height: 8),
                                      const Text(
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
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Produk *',
                        style: DesignSystem.emphasizedBodyTextStyle),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _menuController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: DesignSystem.blackColor),
                      decoration: const InputDecoration(
                        hintText: 'Nama produk',
                        hintStyle: TextStyle(
                          color: DesignSystem.greyColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga pokok/beli *',
                              style: DesignSystem.emphasizedBodyTextStyle),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            style:
                                const TextStyle(color: DesignSystem.blackColor),
                            controller: _hargaPokokController,
                            decoration: const InputDecoration(
                              prefixIcon: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: Text('Rp',
                                      style: TextStyle(
                                        color: DesignSystem.greyColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ))),
                              hintText: 'Harga pokok/beli',
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
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah isi satuan*',
                              style: DesignSystem.emphasizedBodyTextStyle),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _jumlahIsiController,
                            style:
                                const TextStyle(color: DesignSystem.blackColor),
                            decoration: const InputDecoration(
                              hintText: 'Isi',
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
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga jual *',
                              style: DesignSystem.emphasizedBodyTextStyle),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            style:
                                const TextStyle(color: DesignSystem.blackColor),
                            controller: _hargaJualController,
                            decoration: const InputDecoration(
                              prefixIcon: Padding(
                                  padding: EdgeInsets.all(11),
                                  child: Text('Rp',
                                      style: TextStyle(
                                        color: DesignSystem.greyColor,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ))),
                              hintText: 'Harga jual',
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
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stok yang akan dijual*',
                              style: DesignSystem.emphasizedBodyTextStyle),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _stokController,
                            style:
                                const TextStyle(color: DesignSystem.blackColor),
                            decoration: const InputDecoration(
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
                const SizedBox(height: 16.0),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pilih kategori *',
                      style: DesignSystem.emphasizedBodyTextStyle),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    hint: const Text(
                      'Pilih kategori',
                      style: TextStyle(
                        color: DesignSystem.greyColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    value:
                        _selectedCategory.isNotEmpty ? _selectedCategory : null,
                    style: const TextStyle(color: DesignSystem.greyColor),
                    items: const [
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
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deskripsi *',
                        style: DesignSystem.emphasizedBodyTextStyle),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        hintText: 'Masukan deskripsi produk',
                        hintStyle: TextStyle(
                          color: DesignSystem.greyColor,
                          fontWeight: FontWeight.normal,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      style: const TextStyle(color: DesignSystem.blackColor),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitData(context),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text(
                            "Tambah",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
