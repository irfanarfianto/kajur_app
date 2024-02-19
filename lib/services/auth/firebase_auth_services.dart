import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:uuid/uuid.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationToken;
  DateTime? _verificationRequestTime;

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
      await FirebaseFirestore.instance.collection('messages').add({
        'userId': userId,
        'username': username,
        'title': 'Selamat Bergabung $displayName!',
        'subtitle': 'Menyala selalu abangkuhh 🔥🙌',
        'timestamp': Timestamp.now(),
      });

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
        if (!user.emailVerified) {
          return null;
        }

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
    QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
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
