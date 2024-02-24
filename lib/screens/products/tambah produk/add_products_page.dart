import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:kajur_app/screens/products/tambah%20produk/details_add_product.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  final _formKey = GlobalKey<FormState>();

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

    int hargaJual =
        int.tryParse(hargaJualText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int stok = int.tryParse(stokText) ?? 0;
    int hargaPokok =
        int.tryParse(hargaPokokText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    int jumlahIsi = int.tryParse(jumlahIsiText) ?? 0;
    // Validasi input
    if (menu.isNotEmpty &&
        hargaJual > 0 &&
        stok >= 0 &&
        hargaPokok > 0 && // Validasi harga pokok
        jumlahIsi > 0 && // Validasi jumlah isi
        _selectedCategory.isNotEmpty &&
        _selectedImage != null &&
        stokText == stok.toString() &&
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
      showToast(message: 'Mohon isi gambar produknya');
      setState(() {
        _isLoading = false;
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
    return _isLoading
        ? Scaffold(
            body: Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Col.primaryColor, size: 50),
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title: const Text('Tambah Produk'),
            ),
            body: Scrollbar(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 10),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Tambahkan produk baru',
                          style: Typo.headingTextStyle,
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Nama Produk',
                                  style: Typo.emphasizedBodyTextStyle,
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Col.redAccent,
                                    fontWeight: Fw.regular,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _menuController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(color: Col.blackColor),
                              decoration: const InputDecoration(
                                hintText: 'Nama produk',
                                hintStyle: TextStyle(
                                  color: Col.greyColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              maxLength: 500,
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter,
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  if (newValue.text.isEmpty) {
                                    return newValue;
                                  }
                                  return TextEditingValue(
                                    text: newValue.text
                                        .split(' ')
                                        .map((word) => word.isNotEmpty
                                            ? word[0].toUpperCase() +
                                                word.substring(1)
                                            : '')
                                        .join(' '),
                                    selection: newValue.selection,
                                    composing: TextRange.empty,
                                  );
                                }),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Col.greyColor.withOpacity(.50),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  if (_selectedImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _selectedImage!,
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              surfaceTintColor:
                                                  Col.secondaryColor,
                                              title: const Text(
                                                "Pilih Sumber Gambar",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Col.blackColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _getImage(
                                                        ImageSource.gallery);
                                                  },
                                                  child: const Text("Galeri"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _getImage(
                                                        ImageSource.camera);
                                                  },
                                                  child: const Text("Kamera"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.add_a_photo,
                                          size: 30,
                                          color:
                                              Col.greyColor.withOpacity(.20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text('Pilih kategori',
                                            style:
                                                Typo.emphasizedBodyTextStyle),
                                        Text(
                                          '*',
                                          style: TextStyle(
                                            color: Col.redAccent,
                                            fontWeight: Fw.regular,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    DropdownButtonFormField2<String>(
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      hint: const Text(
                                        'Pilih kategori',
                                        style: TextStyle(
                                          color: Col.greyColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      value: _selectedCategory.isNotEmpty
                                          ? _selectedCategory
                                          : null,
                                      style:
                                          const TextStyle(color: Col.greyColor),
                                      items: const [
                                        DropdownMenuItem<String>(
                                          value: 'Makanan',
                                          child: Text(
                                            'Makanan',
                                            style: TextStyle(
                                                color: Col.blackColor,
                                                fontSize: 16),
                                          ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'Minuman',
                                          child: Text(
                                            'Minuman',
                                            style: TextStyle(
                                                color: Col.blackColor,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Col.backgroundColor,
                                            border: Border.all(
                                              color: Col.greyColor
                                                  .withOpacity(.20),
                                            )),
                                      ),
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.only(right: 8),
                                      ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Pilih salah satu kategori';
                                        }
                                        return null;
                                      },
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi (Opsional)',
                              style: Typo.emphasizedBodyTextStyle,
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _deskripsiController,
                              decoration: const InputDecoration(
                                hintText: 'Masukan deskripsi produk',
                                hintStyle: TextStyle(
                                  color: Col.greyColor,
                                  fontWeight: FontWeight.normal,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                              style: const TextStyle(color: Col.blackColor),
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              maxLength: 1000,
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
                                  const Row(
                                    children: [
                                      Text('Harga pokok/beli',
                                          style: Typo.emphasizedBodyTextStyle),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Col.redAccent,
                                          fontWeight: Fw.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextFormField(
                                    style:
                                        const TextStyle(color: Col.blackColor),
                                    controller: _hargaPokokController,
                                    decoration: const InputDecoration(
                                      hintText: 'Harga pokok/beli',
                                      hintStyle: TextStyle(
                                        color: Col.greyColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CurrencyInputFormatter()
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tidak boleh kosong';
                                      }
                                      return null;
                                    },
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
                                  const Row(
                                    children: [
                                      Text('Jumlah isi satuan',
                                          style: Typo.emphasizedBodyTextStyle),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Col.redAccent,
                                          fontWeight: Fw.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _jumlahIsiController,
                                    style:
                                        const TextStyle(color: Col.blackColor),
                                    decoration: const InputDecoration(
                                      hintText: 'Isi',
                                      hintStyle: TextStyle(
                                        color: Col.greyColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tidak boleh kosong';
                                      }
                                      return null;
                                    },
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
                                  const Row(
                                    children: [
                                      Text('Harga jual',
                                          style: Typo.emphasizedBodyTextStyle),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Col.redAccent,
                                          fontWeight: Fw.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextFormField(
                                    style:
                                        const TextStyle(color: Col.blackColor),
                                    controller: _hargaJualController,
                                    decoration: const InputDecoration(
                                      hintText: 'Harga jual',
                                      hintStyle: TextStyle(
                                        color: Col.greyColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CurrencyInputFormatter()
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tidak boleh kosong';
                                      }
                                      return null;
                                    },
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
                                  const Row(
                                    children: [
                                      Text('Stok yang akan dijual',
                                          style: Typo.emphasizedBodyTextStyle),
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Col.redAccent,
                                          fontWeight: Fw.regular,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _stokController,
                                    style:
                                        const TextStyle(color: Col.blackColor),
                                    decoration: const InputDecoration(
                                      hintText: 'Stok',
                                      hintStyle: TextStyle(
                                        color: Col.greyColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitData(context);
                  }
                },
                child: const Center(
                  child: Text(
                    "Tambah",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
