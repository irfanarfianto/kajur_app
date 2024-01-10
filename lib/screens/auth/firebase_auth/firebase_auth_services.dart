import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../global/common/toast.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      // Ngecek apakah username udah kepake sebelum daftar
      if (await isUsernameAvailable(username)) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        User? user = credential.user;

        if (user != null) {
          // Update profil user dengan username yang dimasukin
          await user.updateProfile(displayName: username);

          // Simpan data tambahan user ke Firestore
          await saveUserDataToFirestore(user.uid, username, email);

          return user;
        }
      } else {
        showToast(
            message: 'Username ini udah kepake nih. Pilih yang lain yaa.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle error dari Firebase authentication
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Alamat email udah ada yang pake nih.');
      } else {
        showToast(message: 'Ada kesalahan nih: ${e.code}');
      }
    }
    return null;
  }

  Future<void> saveUserDataToFirestore(
      String userId, String username, String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Ada kesalahan pas nyimpen data user: $e");
      showToast(message: 'Ada kesalahan pas nyimpen data user.');
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;

      if (user != null) {
        // Update timestamp login terakhir
        await updateLastLogin(user.uid);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Email atau password nggak valid.');
      } else {
        showToast(message: 'Ada kesalahan nih: ${e.code}');
      }
    }

    return null;
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'lastLoginAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print("Ada kesalahan pas update waktu login terakhir: $e");
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      print("Ada kesalahan pas ngecek ketersediaan username: $e");
      return false;
    }
  }
}
