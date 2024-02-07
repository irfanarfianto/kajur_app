import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  final String documentId;

  const EditProfilePage({super.key, required this.documentId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _whatsappController;
  late String _photoUrl; // Tambahkan variabel untuk menyimpan URL foto
  late bool _isUpdating;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<String> _profileImageUrls = [];
  late String _selectedImageUrl = ''; // Menyimpan URL foto yang dipilih

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _whatsappController = TextEditingController();
    _isUpdating = false;
    _fetchUserData();
    _fetchProfileImages();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(widget.documentId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _displayNameController.text = data['displayName'];
          _emailController.text = data['email'];
          _usernameController.text = data['username'];
          _whatsappController.text = data['whatsapp'] ?? '';
          _photoUrl = data['photoUrl'] ?? '';
        });

        // Panggil fungsi untuk mendapatkan daftar URL foto
        await _fetchProfileImages();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Fungsi untuk mendapatkan daftar URL foto dari Firebase Storage
  Future<void> _fetchProfileImages() async {
    try {
      ListResult result =
          await FirebaseStorage.instance.ref('foto_profil').listAll();

      // Iterasi melalui setiap item dan ambil URL download-nya
      List<String> urls = [];
      await Future.forEach(result.items, (Reference ref) async {
        String url = await ref.getDownloadURL();
        urls.add(url);
      });

      setState(() {
        _profileImageUrls = urls;
      });
    } catch (e) {
      print('Error fetching profile images: $e');
    }
  }

  // Fungsi untuk menyimpan URL foto yang dipilih ke Firestore
  Future<void> _updateUserData() async {
    try {
      if (_displayNameController.text.isEmpty) {
        // Tampilkan pesan untuk mengisi semua kolom
        return;
      }

      setState(() {
        _isUpdating = true;
      });

      // Lakukan validasi data dan pembaruan ke Firebase Firestore
      await _firestore.collection('users').doc(widget.documentId).update({
        'displayName': _displayNameController.text,
        'whatsapp': _whatsappController.text,
        'updatedAt': Timestamp.now(),
        // Tambahkan update foto jika ada
        'photoUrl':
            _selectedImageUrl.isNotEmpty ? _selectedImageUrl : _photoUrl,
      });

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih gambar '),
                  // update foto
                  if (_profileImageUrls.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _profileImageUrls.length,
                            cacheExtent: 1000,
                            itemBuilder: (context, index) {
                              String imageUrl = _profileImageUrls[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImageUrl = imageUrl;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                imageUrl),
                                        backgroundColor:
                                            _selectedImageUrl == imageUrl
                                                ? Colors.blue
                                                : null,
                                      ),
                                      if (_selectedImageUrl == imageUrl)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _displayNameController,
                    decoration:
                        const InputDecoration(labelText: 'Display Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your display name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _whatsappController,
                    decoration: const InputDecoration(
                        prefix: Text('+62 '), hintText: 'Nomor WhatsApp'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      // Validasi nomor WhatsApp menggunakan regex
                      RegExp whatsappRegExp = RegExp(r'^[0-9]+$');
                      if (value == null || value.isEmpty) {
                        return 'Please enter your WhatsApp number';
                      } else if (!whatsappRegExp.hasMatch(value)) {
                        return 'Invalid WhatsApp number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    enabled: false, // Tidak bisa diedit
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    enabled: false, // Tidak bisa diedit
                  ),
                  const SizedBox(height: 20),
                ],
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
                _updateUserData();
              }
            },
            child: _isUpdating
                ? const CircularProgressIndicator()
                : const Text('Perbarui'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}
