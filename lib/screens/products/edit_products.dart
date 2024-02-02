import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';

class EditProdukPage extends StatefulWidget {
  final String documentId;

  const EditProdukPage({super.key, required this.documentId});

  @override
  // ignore: library_private_types_in_public_api
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _menuController;
  late TextEditingController _hargaJualController;
  late TextEditingController _deskripsiController;

  late CollectionReference _produkCollection;
  File? _selectedImage;
  String? _oldImageUrl;
  late bool _isUpdating;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _oldImageUrl = '';
    _menuController = TextEditingController();
    _hargaJualController = TextEditingController();
    _deskripsiController = TextEditingController();
    _isUpdating = false;
    _fetchProductDetails();
  }

  String formatCurrency(int amount) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return currencyFormatter.format(amount);
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _produkCollection.doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        _menuController.text = data['menu'];
        _hargaJualController.text = formatCurrency(data['hargaJual']);
        _deskripsiController.text = data['deskripsi'];

        setState(() {
          _oldImageUrl = data['image'];
        });
      }
    } catch (e) {}
  }

  Future<void> _updateProductDetails() async {
    try {
      if (_menuController.text.isEmpty || _hargaJualController.text.isEmpty) {
        AnimatedSnackBar.material(
          'Eitss! Jangan ada kolom yang kosong ya',
          type: AnimatedSnackBarType.info,
        ).show(context);
        return;
      }

      setState(() {
        _isUpdating = true;
      });

      String hargaJualText = _hargaJualController.text;
      int newHargaJual =
          int.tryParse(hargaJualText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      // Validasi input
      if (newHargaJual >= 0) {
        User? user = FirebaseAuth.instance.currentUser;
        String? userId = user?.uid;
        String? userName = user?.displayName ?? 'Unknown User';

        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImage();
        } else {
          imageUrl = _oldImageUrl;
        }

        // Mendapatkan detail produk sebelum diperbarui
        DocumentSnapshot oldProductSnapshot =
            await _produkCollection.doc(widget.documentId).get();
        Map<String, dynamic> oldProductData =
            oldProductSnapshot.data() as Map<String, dynamic>;

        num newProfitSatuan = newHargaJual -
            (oldProductData['hargaPokok'] / oldProductData['jumlahIsi'])
                .toInt();
        num newTotalProfit = newProfitSatuan * oldProductData['jumlahIsi'];

        // Merekam log aktivitas
        await _recordActivityLog(
          action: 'Edit Produk',
          oldProductData: oldProductData,
          productName: _menuController.text,
          newProductData: {
            'menu': _menuController.text,
            'hargaJual': newHargaJual,
            'deskripsi': _deskripsiController.text,
            'image': imageUrl,
            'totalProfit': newTotalProfit,
            'profitSatuan': newProfitSatuan,
          },
        );

        await _produkCollection.doc(widget.documentId).update({
          'menu': _menuController.text,
          'hargaJual': newHargaJual,
          'deskripsi': _deskripsiController.text,
          'image': imageUrl,
          'totalProfit': newTotalProfit,
          'profitSatuan': newProfitSatuan,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastEditedBy': userId,
          'lastEditedByName': userName,
        });

        // ignore: use_build_context_synchronously
        AnimatedSnackBar.material(
          'Produk berhasil diperbarui',
          type: AnimatedSnackBarType.success,
        ).show(context);

        setState(() {
          _isUpdating = false;
        });

        Navigator.pop(context);
      } else {
        AnimatedSnackBar.material(
          'Mohon isi harga dan stok dengan angka',
          type: AnimatedSnackBarType.info,
        ).show(context);
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
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
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit Produk'),
      ),
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Pilih Sumber Gambar"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _getImage(ImageSource.gallery);
                                },
                                child: const Row(
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
                                child: const Row(
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
                        color: Col.greyColor.withOpacity(.20),
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
                              : const Center(
                                  child: Icon(Icons.add_a_photo),
                                ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Produk',
                          style: Typo.emphasizedBodyTextStyle),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tidak boleh kosong';
                          }
                          return null;
                        },
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
                            const Text('Harga Jual',
                                style: Typo.emphasizedBodyTextStyle),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              style: const TextStyle(color: Col.blackColor),
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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Deskripsi',
                          style: Typo.emphasizedBodyTextStyle),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tidak boleh kosong';
                          }
                          return null;
                        },
                        maxLength: 1000,
                        style: const TextStyle(color: Col.blackColor),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),
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
                _updateProductDetails();
              }
            },
            child: Center(
              child: _isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ))
                  : const Text(
                      "Update",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _hargaJualController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}
