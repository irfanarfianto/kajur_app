import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/screens/widget/form_container_widget.dart';

class EditProdukPage extends StatefulWidget {
  final String documentId;

  const EditProdukPage({Key? key, required this.documentId}) : super(key: key);

  @override
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _menuController;
  late TextEditingController _hargaController;

  late CollectionReference _produkCollection;

  @override
  void initState() {
    super.initState();
    _produkCollection = FirebaseFirestore.instance.collection('kantin');

    _menuController = TextEditingController();
    _hargaController = TextEditingController();

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

      await _produkCollection.doc(widget.documentId).update({
        'menu': _menuController.text,
        'harga': int.tryParse(_hargaController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastEditedBy': userId,
        'lastEditedByName': userName,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating product details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormContainerWidget(
              controller: _menuController,
              hintText: 'Menu',
            ),
            SizedBox(height: 16.0),
            FormContainerWidget(
              controller: _hargaController,
              hintText: 'Harga',
              inputType: TextInputType.number,
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
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _hargaController.dispose();
    super.dispose();
  }
}
