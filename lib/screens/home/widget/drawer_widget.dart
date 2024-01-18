// drawer_widget.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';

class DrawerWidget extends StatelessWidget {
  final User? currentUser;
  final Function confirmSignOut;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  DrawerWidget(
      {super.key, required this.currentUser, required this.confirmSignOut});

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
              child: const Text("Cancel",
                  style: TextStyle(color: DesignSystem.greyColor)),
            ),
            TextButton(
              onPressed: () {
                _signOut(context); // Pass context to _signOut
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Keluar",
                  style: TextStyle(color: DesignSystem.redAccent)),
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildDrawerHeader(currentUser),
        const Spacer(),
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.redAccent,
            ),
            onPressed: () => _confirmSignOut(context), // Pass context
            label: const Text('Keluar'),
            icon: const Icon(Icons.exit_to_app),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader(User? currentUser) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: DesignSystem.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          currentUser != null
              ? Text(
                  "${currentUser.displayName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                )
              : const CircularProgressIndicator(), // Show loading indicator while fetching user data
          const SizedBox(height: 5),
          currentUser != null
              ? Text(
                  "${currentUser.email}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                )
              : const CircularProgressIndicator(), // Show loading indicator while fetching user data
        ],
      ),
    );
  }
}
