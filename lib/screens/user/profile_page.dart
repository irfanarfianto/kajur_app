import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kajur_app/animation/route/slide_left.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/user/edit_profile_page.dart';
import 'package:kajur_app/admin/manage_user_role.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserProfilePage extends StatefulWidget {
  final User? currentUser;

  const UserProfilePage({super.key, required this.currentUser});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late User? user;
  bool isAdmin = false;
  bool isStaf = false;
  bool isBiasa = false;
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
                  const SizedBox(height: 16),
                  _buildAppVersion(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        } else if (snapshot.hasData) {
          return Text(
            'Versi ${snapshot.data!.version}',
            style: const TextStyle(
              color: Col.blackColor,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildUserWidget(
      BuildContext context, User? currentUser, String? photoUrl) {
    if (currentUser == null) {
      return const CircularProgressIndicator(
        color: Colors.white,
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
              child: CircleAvatar(
                radius: 40,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      "${currentUser.displayName}",
                      style: Typo.headingTextStyle,
                    ),
                    const SizedBox(width: 4),
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
                    ),
                  ],
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
                        SlideLeftRoute(
                            page: EditProfilePage(
                          documentId: currentUser.uid,
                        )));
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
                      Icons.auto_awesome_mosaic_outlined,
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
                    childAspectRatio: 1.2,
                    crossAxisCount:
                        2, // Sesuaikan jumlah kolom sesuai kebutuhan
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
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            style: Typo.emphasizedBodyTextStyle,
          ),
          Text(
            '$count kali',
            style: const TextStyle(fontSize: 12, color: Col.greyColor),
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
                      Icons.manage_accounts_outlined,
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
                      Icons.settings_outlined,
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
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      // showToast(message: "Berhasil keluar");
    } catch (e) {
      showToast(message: "Error signing out: $e");
    }
  }
}
