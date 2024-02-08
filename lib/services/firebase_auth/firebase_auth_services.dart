import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../global/common/toast.dart';
import 'package:uuid/uuid.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationToken;
  DateTime? _verificationRequestTime;

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
      bool isUsernameTaken = await isUsernameAlreadyTaken(username);

      if (isUsernameTaken) {
        showToast(message: 'Username sudah digunakan, pilih yang lain.');
        return null;
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = credential.user;

      if (user != null) {
        // Kirim email verifikasi jika pengguna belum diverifikasi sebelumnya
        await _sendEmailVerification(user);

        await saveUserDataToFirestore(
          user.uid,
          username,
          email,
          user.displayName ?? '',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Alamat email sudah digunakan.');
      } else {
        showToast(message: 'Terjadi kesalahan: ${e.code}');
      }
    }
    return null;
  }

  Future<void> _sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      if (!isVerificationTokenValid()) {
        // Jika token verifikasi tidak valid, buat token baru
        _verificationToken = generateVerificationToken();
        _verificationRequestTime = DateTime.now();
      }

      try {
        await user.sendEmailVerification();
        showToast(message: 'Email verifikasi telah dikirim ke ${user.email}');
      } catch (e) {
        showToast(message: 'Gagal mengirim email verifikasi: $e');
      }
    } else {
      showToast(message: 'Alamat email sudah diverifikasi.');
    }
  }

  String generateVerificationToken() {
    var uuid = Uuid();
    return uuid.v4();
  }

  bool isVerificationTokenValid() {
    if (_verificationRequestTime == null || _verificationToken == null) {
      return false;
    }

    final currentTime = DateTime.now();
    final difference = currentTime.difference(_verificationRequestTime!);
    if (difference.inMinutes > 2) {
      // Waktu sudah lebih dari 2 menit, token tidak valid
      return false;
    }

    return true;
  }

  void disableVerificationToken() {
    _verificationToken = null;
    _verificationRequestTime = null;
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
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        // Periksa apakah email pengguna telah diverifikasi
        if (!user.emailVerified) {
          return null;
        }

        // Update timestamp login terakhir
        await updateLastLogin(user.uid);
      }

      return user;
    } on FirebaseAuthException {
      showToast(message: 'Akun tidak ditemukan');
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
