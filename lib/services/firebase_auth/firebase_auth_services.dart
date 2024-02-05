import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../global/common/toast.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<User?> signUpWithGoogle(AuthCredential credential) async {
  //   try {
  //     UserCredential authResult = await _auth.signInWithCredential(credential);
  //     User? user = authResult.user;

  //     if (user != null) {
  //       // Update timestamp login terakhir
  //       await updateLastLogin(user.uid);

  //       // Cek apakah user sudah terdaftar di Firestore
  //       if (!(await isUserRegistered(user.uid))) {
  //         // Jika belum terdaftar, simpan data user ke Firestore
  //         await saveUserDataToFirestore(
  //           user.uid,
  //           user.displayName ?? '',
  //           user.email ?? '',
  //           user.displayName ?? '',
  //         );
  //       }

  //       // Menampilkan pesan toast selamat datang
  //       showToast(message: "Selamat datang, ${user.displayName}!");

  //       return user;
  //     }
  //   } catch (e) {
  //     showToast(message: "Terjadi kesalahan: $e");
  //   }

  //   return null;
  // }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      // Cek apakah username sudah digunakan
      bool isUsernameTaken = await isUsernameAlreadyTaken(username);

      if (isUsernameTaken) {
        showToast(message: 'Username sudah digunakan, pilih yang lain.');
        return null;
      }

      // Jika username belum digunakan, lanjutkan dengan pembuatan pengguna
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;

      if (user != null) {
        // Update profil user dengan username yang dimasukkan
        // ignore: deprecated_member_use
        await user.updateProfile(displayName: username);

        // Simpan data tambahan user ke Firestore
        await saveUserDataToFirestore(
            user.uid, username, email, user.displayName ?? '');

        return user;
      }
    } on FirebaseAuthException catch (e) {
      // Handle error dari Firebase authentication
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Alamat email sudah digunakan.');
      } else {
        showToast(message: 'Terjadi kesalahan: ${e.code}');
      }
    }
    return null;
  }

  Future<void> saveUserDataToFirestore(
      String userId, String username, String email, String displayName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'displayName': displayName,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'role': 'biasa', // Tambahkan informasi peran di sini
      });
    } catch (e) {
      showToast(message: 'Error saving user data to Firestore.');
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
    } catch (e) {}
  }

  Future<bool> isUsernameAlreadyTaken(String username) async {
    // Lakukan pemeriksaan ke Firestore atau database lainnya
    // untuk mengecek apakah username sudah ada atau belum
    // Anda dapat menggunakan Firestore atau database lain sesuai kebutuhan

    // Contoh penggunaan Firestore
    QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Clear the previous GoogleSignInAccount
      await googleSignIn.signOut();

      // Jika pengguna belum masuk, minta untuk memilih akun Google
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential authResult =
            await _auth.signInWithCredential(credential);
        User? user = authResult.user;

        if (user != null) {
          // Update timestamp login terakhir
          await updateLastLogin(user.uid);

          // Cek apakah user sudah terdaftar di Firestore
          if (!(await isUserRegistered(user.uid))) {
            // Jika belum terdaftar, simpan data user ke Firestore
            await saveUserDataToFirestore(user.uid, user.displayName ?? '',
                user.email ?? '', user.displayName ?? '');
          }

          // Menampilkan pesan toast selamat datang
          showToast(message: "Selamat datang, ${user.displayName}!");

          return user;
        }
      }
    } catch (e) {
      showToast(message: "Terjadi kesalahan: $e");
    }

    return null;
  }

  Future<bool> isUserRegistered(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }
}
