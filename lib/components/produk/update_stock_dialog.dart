import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';

final CollectionReference _produkCollection =
    FirebaseFirestore.instance.collection('kantin');

void showUpdateStokDialog(
  BuildContext context,
  String documentId,
  String productName,
  int lastStock,
  String imageUrl,
) {
  TextEditingController stokController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Builder(
        builder: (context) {
          // Gunakan konteks yang valid di sini
          return AlertDialog(
            surfaceTintColor: Col.secondaryColor,
            backgroundColor: Col.secondaryColor,
            title: Row(
              children: [
                const Icon(
                  Icons.update,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text('Update Stok', style: Typo.titleTextStyle),
              ],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'product_image_$documentId',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                  color: Col.greyColor.withOpacity(0.10),
                                  child: Icon(Icons.hide_image_rounded,
                                      color: Col.greyColor.withOpacity(0.50))),
                              placeholder: (context, url) => Container(
                                  color: Col.greyColor.withOpacity(0.10),
                                  child: Icon(Icons.image,
                                      color: Col.greyColor.withOpacity(0.50))),
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName.isEmpty
                                    ? 'Loading...'
                                    : productName,
                                style: Typo.emphasizedBodyTextStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                lastStock == 0
                                    ? 'Stok sudah habis'
                                    : 'Sisa stok $lastStock',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: lastStock == 0
                                      ? Col.redAccent
                                      : Col.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        controller: stokController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok Baru',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Stok harus diisi';
                          }
                          // Validasi jika nilai bukan angka
                          if (int.tryParse(value) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          // Validasi jika nilai negatif
                          if (int.parse(value) < 0) {
                            return 'Stok tidak boleh negatif';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    int newStock = int.tryParse(stokController.text) ?? 0;
                    _updateStock(context, documentId, newStock);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _updateStock(
  BuildContext context,
  String documentId,
  int newStock,
) async {
  try {
    // Fetch the old product data before updating the stock
    DocumentSnapshot oldProductSnapshot =
        await _produkCollection.doc(documentId).get();
    Map<String, dynamic> oldProductData =
        oldProductSnapshot.data() as Map<String, dynamic>;

    // Perform the stock update
    await FirebaseFirestore.instance
        .collection('kantin')
        .doc(documentId)
        .update({
      'stok': newStock,
      'updatedAt': DateTime.now(),
    });
    

    // Record activity log using the old product data
    await _recordActivityLog(
      action: 'Update Stok',
      productId: documentId,
      oldProductData: oldProductData,
      newProductData: {
        'stok': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      context: context,
    );

    showToast(message: 'Stok produk berhasil diperbarui');
  } catch (error) {
    showToast(message: 'Gagal memperbarui stok produk');
  }
}

Future<void> _recordActivityLog({
  required BuildContext context,
  required String action,
  required String productId,
  required Map<String, dynamic> oldProductData,
  required Map<String, dynamic> newProductData,
}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(message: 'User not authenticated', code: '');
    }

    String userId = user.uid;
    String userName = user.displayName ?? 'Unknown User';

    // Create reference to activity log collection
    CollectionReference activityLogCollection =
        FirebaseFirestore.instance.collection('activity_log');

    // Record activity log to collection
    await activityLogCollection.add({
      'userId': userId,
      'userName': userName,
      'action': action,
      'productId': productId,
      'productName': oldProductData['menu'],
      'oldProductData': oldProductData,
      'newProductData': newProductData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (error) {
    showToast(message: 'Gagal menambahkan log aktivitas');
  }
}
