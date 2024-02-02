import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/design/system.dart';

class UpdateStokProdukPage extends StatefulWidget {
  final String documentId;

  const UpdateStokProdukPage({
    super.key,
    required this.documentId,
  });

  @override
  _UpdateStokProdukPageState createState() => _UpdateStokProdukPageState();
}

class _UpdateStokProdukPageState extends State<UpdateStokProdukPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stokController;
  late CollectionReference _produkCollection;
  int _previousStok = 0;
  String _productName = '';
  late bool _isUpdating;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');
    _stokController = TextEditingController();
    _fetchProductDetails();
    _isUpdating = false;
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _produkCollection.doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _productName = data['menu'] ?? '';
          _previousStok = data['stok'] ?? 0;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _updateStok() async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      int newStok = int.tryParse(_stokController.text) ?? 0;

      if (newStok < 0) {
        showToast(message: 'Stok tidak boleh kurang dari 0');
        return;
      }

      // Set isUpdating to true to show the circular progress indicator
      setState(() {
        _isUpdating = true;
      });

      // Fetch the old product data
      DocumentSnapshot oldProductSnapshot =
          await _produkCollection.doc(widget.documentId).get();
      Map<String, dynamic> oldProductData =
          oldProductSnapshot.data() as Map<String, dynamic>;

      // Update the stock and updatedAt field
      await _produkCollection.doc(widget.documentId).update({
        'stok': newStok,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Record activity log
      await _recordActivityLog(
        action: 'Update Stok',
        oldProductData: oldProductData,
        newProductData: {
          'stok': newStok,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      showToast(message: 'Stok produk berhasil diupdate');

      // Set isUpdating back to false after the update process is completed
      setState(() {
        _isUpdating = false;
      });

      Navigator.pop(context);
    } catch (e) {
      showToast(message: 'Terjadi kesalahan saat mengupdate stok produk');

      // Set isUpdating back to false in case of an error
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required Map<String, dynamic> oldProductData,
    required Map<String, dynamic> newProductData,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;
      String? userName = user?.displayName ?? 'Unknown User';

      // Create reference to activity log collection
      CollectionReference activityLogCollection =
          FirebaseFirestore.instance.collection('activity_log');

      // Record activity log to collection
      await activityLogCollection.add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'productName': oldProductData['menu'],
        'oldProductData': oldProductData,
        'newProductData': newProductData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  String? _validateStok(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan jumlah stok baru';
    }

    int? parsedValue = int.tryParse(value);

    if (parsedValue == null || parsedValue < 0) {
      return 'Stok tidak valid';
    }

    // Check for decimal numbers or numbers with leading zeros
    if (value.contains('.') || value.startsWith('0')) {
      return 'Masukkan angka bulat positif';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Stok Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    _productName.isEmpty ? 'Loading...' : _productName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: Fw.bold),
                  ),
                  const Text(
                    'Stok Sebelumnya',
                    style: TextStyle(
                        fontSize: 16, fontWeight: Fw.regular),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_previousStok',
                          style: const TextStyle(
                              fontSize: 100, fontWeight: Fw.regular),
                        ),
                        const Text(
                          '/pcs',
                          style: TextStyle(
                              fontSize: 50, fontWeight: Fw.regular),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                validator: _validateStok,
                decoration: const InputDecoration(
                  labelText: 'Stok Baru',
                  hintText: 'Masukkan jumlah stok baru',
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateStok,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Col.whiteColor,
                        backgroundColor: _isUpdating
                            ? Col.primaryColor
                            : null, // Set blue color when updating
                      ).copyWith(
                        elevation: ButtonStyleButton.allOrNull(0.0),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          if (_isUpdating) {
                            return Col
                                .primaryColor; // Set blue color when updating
                          }
                          return Col
                              .primaryColor; // Default color when not updating
                        }),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Stok'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stokController.dispose();
    super.dispose();
  }
}
