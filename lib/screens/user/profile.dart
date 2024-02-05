import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/user/edit_profile.dart';

class UserProfilePage extends StatelessWidget {
  final User? currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserProfilePage({Key? key, required this.currentUser}) : super(key: key);

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
                _buildUserWidget(context, currentUser),
                const SizedBox(height: 16),
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
                Text("${currentUser.displayName}",
                    style: Typo.headingTextStyle),
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
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      showToast(message: "Berhasil keluar");
    } catch (e) {
      showToast(message: "Error signing out: $e");
    }
  }
}
