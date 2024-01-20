import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/global/common/toast.dart';

class UserProfilePage extends StatelessWidget {
  final User? currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUserWidget(currentUser),
              const Spacer(),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserWidget(User? currentUser) {
    if (currentUser == null) {
      return const CircularProgressIndicator(
        color: Colors.white, // Adjust the color as needed
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('images/avatar.png'),
            radius: 50,
          ),
          const SizedBox(height: 16),
          Text("${currentUser.displayName}",
              style: DesignSystem.headingTextStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                color: DesignSystem.greyColor,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                "${currentUser.email}",
                style: const TextStyle(
                  color: Colors.grey, // Adjust the color as needed
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
}
