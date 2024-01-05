import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kajur_app/screens/widget/form_container_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
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

    if (menu.isNotEmpty &&
        harga > 0 &&
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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'addedBy': userId,
        'addedByName': userName,
        'lastEditedBy': userId, 
        'lastEditedByName':
            userName, 
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
          content: Text('Mohon isi semua bidang'),
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
        title: Text('Add Data'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _getImage(),
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      width: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.add_a_photo),
                    ),
            ),
            SizedBox(height: 16.0),
            FormContainerWidget(
              controller: _menuController,
              hintText: 'Menu',
            ),
            SizedBox(height: 16.0),
            FormContainerWidget(
              controller: _hargaController,
              hintText: 'Harga',
              // number
              inputType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Makanan',
                  child: Text('Makanan'),
                ),
                DropdownMenuItem(
                  value: 'Minuman',
                  child: Text('Minuman'),
                ),
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value ?? '';
                });
              },
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
    );
  }
}
