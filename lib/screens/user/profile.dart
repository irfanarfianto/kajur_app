import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _currentUser;
  String _defaultAvatar =
      'https://example.com/default_avatar.png'; // URL gambar default

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _showImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('profile_${DateTime.now()}.jpg');
      TaskSnapshot task = await ref.putFile(File(pickedFile.path));
      String newImageUrl = await task.ref.getDownloadURL();
      await _currentUser?.updatePhotoURL(newImageUrl);

      setState(() {
        // Remove the following line as it's not needed
        // _currentUser?.updatePhotoURL(newImageUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _currentUser != null
          ? Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showImagePicker(); // Panggil fungsi untuk memilih foto baru
                    },
                    child: _buildProfileImage(),
                  ),
                  SizedBox(height: 20),
                  _buildUserInfo(),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 70,
      backgroundImage: _currentUser!.photoURL != null
          ? NetworkImage(_currentUser!.photoURL!)
          : NetworkImage(_defaultAvatar),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _currentUser!.displayName ?? 'No Name',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          _currentUser!.email ?? 'No Email',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Implement action for editing profile
          },
          child: Text('Edit Profile'),
        ),
      ],
    );
  }
}
