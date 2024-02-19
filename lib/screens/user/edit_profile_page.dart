import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late String _photoUrl;
  late bool _isUpdating;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<String> _profileImageUrls = [];
  late String _selectedImageUrl = '';
  int _currentLoadedImages = 0;
  final int _initialLoadLimit = 7;
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _whatsappController = TextEditingController();
    _isUpdating = false;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchUserData();
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

        await _fetchProfileImages();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProfileImages() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? storedUrls = prefs.getStringList('profileImageUrls');

      if (storedUrls != null && storedUrls.isNotEmpty) {
        setState(() {
          _profileImageUrls = storedUrls;
        });
      } else {
        ListResult result =
            await FirebaseStorage.instance.ref('foto_profil').listAll();

        List<String> urls = [];
        for (Reference ref in result.items) {
          if (_currentLoadedImages < _initialLoadLimit) {
            String url = await ref.getDownloadURL();
            urls.add(url);
            _currentLoadedImages++;
          } else {
            break;
          }
        }

        prefs.setStringList('profileImageUrls', urls);

        setState(() {
          _profileImageUrls = urls;
        });
      }
    } catch (e) {
      print('Error fetching profile images: $e');
    }
  }

  Future<void> _loadMoreImages() async {
    try {
      if (!_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });

        ListResult result =
            await FirebaseStorage.instance.ref('foto_profil').listAll();

        List<String> urls = [];
        await Future.forEach(result.items, (Reference ref) async {
          if (_profileImageUrls.length <
              _currentLoadedImages + _initialLoadLimit) {
            String url = await ref.getDownloadURL();
            urls.add(url);
            _currentLoadedImages++;
          }
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedUrls = prefs.getStringList('profileImageUrls');
        if (storedUrls != null) {
          storedUrls.addAll(urls);
          prefs.setStringList('profileImageUrls', storedUrls);
        } else {
          prefs.setStringList('profileImageUrls', urls);
        }

        setState(() {
          _profileImageUrls.addAll(urls);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error fetching more profile images: $e');
    }
  }

  Future<void> _updateUserData() async {
    if (_displayNameController.text.isEmpty) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Update user data
      await _firestore.collection('users').doc(widget.documentId).update({
        'displayName': _displayNameController.text,
        'whatsapp': _whatsappController.text,
        'updatedAt': Timestamp.now(),
        'photoUrl':
            _selectedImageUrl.isNotEmpty ? _selectedImageUrl : _photoUrl,
      });

      // Save updated user data to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('displayName', _displayNameController.text);
      prefs.setString('whatsapp', _whatsappController.text);
      prefs.setString('photoUrl',
          _selectedImageUrl.isNotEmpty ? _selectedImageUrl : _photoUrl);

      // Send back the updated photoUrl to the previous screen
      Navigator.pop(context, _selectedImageUrl);
    } catch (e) {
      print('Error updating user data: $e');
      // Handle error if needed
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreImages();
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
        body: _isUpdating
            ? Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: Col.primaryColor, size: 50),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Pilih gambar '),
                      ),
                      // Tampilkan daftar gambar
                      if (_profileImageUrls.isNotEmpty)
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              for (int i = 0; i < _profileImageUrls.length; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImageUrl =
                                            _profileImageUrls[i];
                                      });
                                    },
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            _profileImageUrls[i],
                                          ),
                                          backgroundColor: _selectedImageUrl ==
                                                  _profileImageUrls[i]
                                              ? Colors.blue
                                              : null,
                                        ),
                                        if (_selectedImageUrl ==
                                            _profileImageUrls[i])
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              height: 24,
                                              width: 24,
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Col.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Col.secondaryColor,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_isLoadingMore)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child:
                                        LoadingAnimationWidget.prograssiveDots(
                                      color: Col.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Tampilkan indikator loading jika belum ada gambar yang dimuat
                      if (_profileImageUrls.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: LoadingAnimationWidget.prograssiveDots(
                              color: Col.primaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                              ),
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
                                prefix: Text('+62 '),
                                hintText: 'Nomor WhatsApp',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
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
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              enabled: false,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              enabled: false,
                            ),
                          ],
                        ),
                      ),
                    ],
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
            child: const Text('Perbarui'),
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
    _scrollController.dispose();
    super.dispose();
  }
}
