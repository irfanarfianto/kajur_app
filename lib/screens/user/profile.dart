import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/user/edit_profile.dart';
import 'package:kajur_app/screens/user/user_role.dart';

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

          setState(() {
            isAdmin = userRole == 'admin';
            isStaf = userRole == 'staf';
            isBiasa = userRole == 'biasa';
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUserWidget(context, widget.currentUser),
                const SizedBox(height: 16),
                _buildUserManagementWidget(context),
                const Spacer(),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserWidget(BuildContext context, User? currentUser) {
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
              child: const CircleAvatar(
                backgroundImage: AssetImage('images/avatar.png'),
                radius: 30,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
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

  Color _getBadgeColor() {
    if (isAdmin) {
      return Colors.blue; // Ganti dengan warna sesuai dengan role Admin
    } else if (isStaf) {
      return Colors.green; // Ganti dengan warna sesuai dengan role Staf
    } else if (isBiasa) {
      return Colors.orange; // Ganti dengan warna sesuai dengan role User Biasa
    } else {
      return Colors.black; // Ganti dengan warna default atau sesuai kebutuhan
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Col.redAccent,
      ),
      onPressed: () => _confirmSignOut(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.exit_to_app),
          SizedBox(width: 10),
          Text(
            'Keluar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget _buildUserManagementWidget(BuildContext context) {
    // Check user role here
    // If the user role is not 'admin', display user management widget
    if (isAdmin) {
      return Container(
        padding: const EdgeInsets.all(8.0),
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
                height: 50,
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
                height: 50,
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
        padding: const EdgeInsets.all(8.0),
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
                height: 50,
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
}
