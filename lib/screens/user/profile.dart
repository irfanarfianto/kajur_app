import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/user/edit_profile.dart';
import 'package:kajur_app/screens/user/user_role.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';

class UserProfilePage extends StatefulWidget {
  final User? currentUser;

  const UserProfilePage({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late User? user;
  bool isAdmin = false;
  bool isStaf = false;
  bool isBiasa = false;
  File? _selectedImage;
  late String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkUserRole();
  }

  void _checkUserRole() {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot document) {
        if (document.exists) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          String? userRole = userData['role'];
          String? photoUrl =
              userData['photoUrl']; // Ambil URL foto profil dari Firestore

          setState(() {
            isAdmin = userRole == 'admin';
            isStaf = userRole == 'staf';
            isBiasa = userRole == 'biasa';
            _photoUrl = photoUrl!; // Atur nilai _photoUrl
          });
        }
      }).catchError((error) {
        print("Error getting user role: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        backgroundColor: Col.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          surfaceTintColor: Col.backgroundColor,
          backgroundColor: Col.backgroundColor,
          title: const Text('Profil'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildUserWidget(context, widget.currentUser, _photoUrl),

                  const SizedBox(height: 16),
                  _buildUserHistoryWidget(context),
                  const SizedBox(height: 16),
                  _buildUserManagementWidget(context),
                  // const SizedBox(height: 16),
                  // _uploadFotoProfil(context),
                  const SizedBox(height: 16),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserWidget(
      BuildContext context, User? currentUser, String? photoUrl) {
    if (currentUser == null) {
      return const CircularProgressIndicator(
        color: Colors.white, // Adjust the color as needed
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Col.secondaryColor,
          border: Border.all(color: Col.greyColor.withOpacity(.10)),
          boxShadow: [
            BoxShadow(
              color: Col.greyColor.withOpacity(.10),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: currentUser.uid,
              child: ClipOval(
                child: Image.network(
                  photoUrl ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Col.greyColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: _getBadgeColor(),
                  label: Text(
                    isAdmin
                        ? 'Admin'
                        : isStaf
                            ? 'Staf'
                            : isBiasa
                                ? 'User Biasa'
                                : '',
                    style: const TextStyle(
                      color: Col.whiteColor,
                    ),
                  ),
                  child: Text(
                    "${currentUser.displayName}",
                    style: Typo.headingTextStyle,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email,
                      color: Col.greyColor,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text("${currentUser.email}",
                        style: Typo.emphasizedBodyTextStyle),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                                documentId: currentUser.uid,
                              )),
                    );
                  },
                  child: const Text('Edit profil',
                      style: Typo.emphasizedBodyTextStyle),
                )
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildUserHistoryWidget(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activity_log')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<DocumentSnapshot> documents = snapshot.data!.docs;

          List<String> allActionTypes = [
            'Tambah Produk',
            'Edit Produk',
            'Update Stok',
            'Hapus Produk',
            // Tambahkan jenis aksi lainnya sesuai kebutuhan
          ];

          Map<String, int> actionCountMap = {};

          for (var document in documents) {
            String action = document['action'];
            actionCountMap[action] = (actionCountMap[action] ?? 0) + 1;
          }

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Col.secondaryColor,
              border: Border.all(color: Col.greyColor.withOpacity(.10)),
              boxShadow: [
                BoxShadow(
                  color: Col.greyColor.withOpacity(.10),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.history,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Rangkuman',
                      style: Typo.emphasizedBodyTextStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.5,
                    crossAxisCount:
                        2, // Sesuaikan jumlah kolom sesuai kebutuhan
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: allActionTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    String actionName = allActionTypes[index];
                    int count = actionCountMap[actionName] ?? 0;
                    return _buildActionSummary(actionName, count);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildActionSummary(String actionName, int count) {
    return Container(
      padding: const EdgeInsets.all(12.0), // Sesuaikan ukuran padding
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20), // Sesuaikan ukuran borderRadius
        color: Col.secondaryColor,
        border: Border.all(color: Col.greyColor.withOpacity(.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActivityIcon(
            action: actionName,
          ),
          const SizedBox(height: 8),
          Text(
            actionName,
            style: Typo.emphasizedBodyTextStyle, // Sesuaikan ukuran font teks
          ),
          Text(
            '$count kali',
            style: const TextStyle(
                fontSize: 12,
                color: Col.greyColor), // Sesuaikan ukuran font teks
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor() {
    if (isAdmin) {
      return Colors.red;
    } else if (isStaf) {
      return Colors.blue;
    } else if (isBiasa) {
      return Colors.green;
    } else {
      return Colors.black;
    }
  }

  Widget _buildUserManagementWidget(BuildContext context) {
    // Check user role here
    // If the user role is not 'admin', display user management widget
    if (isAdmin) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Col.secondaryColor,
          border: Border.all(color: Col.greyColor.withOpacity(.10)),
          boxShadow: [
            BoxShadow(
              color: Col.greyColor.withOpacity(.10),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // ManageUserRolePage
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageUserRolePage()));
              },
              child: const SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Icon(
                      Icons.manage_accounts,
                    ),
                    SizedBox(width: 10),
                    Text('Manajemen User', style: Typo.emphasizedBodyTextStyle),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: Col.greyColor.withOpacity(0.2),
            ),
            InkWell(
              highlightColor: Colors.grey,
              onTap: () {
                print(' Navigasi ke halaman pengaturan');
              },
              child: const SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                    ),
                    SizedBox(width: 10),
                    Text('Pengaturan', style: Typo.emphasizedBodyTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Return an empty container if the user is not an admin
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Col.secondaryColor,
          border: Border.all(color: Col.greyColor.withOpacity(.10)),
          boxShadow: [
            BoxShadow(
              color: Col.greyColor.withOpacity(.10),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              highlightColor: Colors.grey,
              onTap: () {
                print(' Navigasi ke halaman pengaturan');
              },
              child: const SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                    ),
                    SizedBox(width: 10),
                    Text('Pengaturan', style: Typo.emphasizedBodyTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _uploadFotoProfil(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Col.secondaryColor,
        border: Border.all(color: Col.greyColor.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Col.greyColor.withOpacity(.10),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _getImage(ImageSource.gallery);
        },
        child: SizedBox(
          height: 30,
          child: Row(
            children: [
              Icon(
                Icons.photo_camera, // Ganti ikon dengan ikon kamera atau galeri
                color: Col.redAccent.withOpacity(0.5),
              ),
              const SizedBox(width: 10),
              const Text(
                'Upload Foto',
                style: TextStyle(fontSize: 14, color: Col.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // Add this line to display a dialog after image is selected
      _showDialog();
    } else {
      print('No image selected.');
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Selected'),
          content: Text('Do you want to upload this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _uploadImage();
                // You can call _uploadImage() here to start uploading the image
                Navigator.of(context).pop();
              },
              child: Text('Upload'),
            ),
          ],
        );
      },
    );
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
        .child('foto_profile')
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(compressedFile);

    return await ref.getDownloadURL();
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Col.secondaryColor,
        border: Border.all(color: Col.greyColor.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Col.greyColor.withOpacity(.10),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _confirmSignOut(context);
        },
        child: SizedBox(
          height: 30,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Col.redAccent.withOpacity(0.5),
              ),
              const SizedBox(width: 10),
              const Text(
                'Keluar',
                style: TextStyle(fontSize: 14, color: Col.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text("Konfirmasi"),
          content: const Text("Aapakah kamu yakin untuk keluar?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Col.greyColor)),
            ),
            TextButton(
              onPressed: () {
                _signOut(context); // Pass context to _signOut
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  const Text("Keluar", style: TextStyle(color: Col.redAccent)),
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      showToast(message: "Berhasil keluar");
    } catch (e) {
      showToast(message: "Error signing out: $e");
    }
  }
}
