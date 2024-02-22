import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProdukService {
  final CollectionReference _produkCollection =
      FirebaseFirestore.instance.collection('kantin');

  Stream<QuerySnapshot> get produkStream => _produkCollection.snapshots();

  Future<String?> getUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return userData['role'];
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<void> deleteProduct(String documentId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _produkCollection.doc(documentId).get();
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      await _recordActivityLog(
        action: 'Hapus Produk',
        productId: documentId,
        productName: productData['menu'],
        productData: productData,
      );

      await _produkCollection.doc(documentId).delete();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _recordActivityLog({
    required String action,
    required String productId,
    required String productName,
    required Map<String, dynamic> productData,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;
      String? userName = user?.displayName ?? 'Unknown User';

      CollectionReference activityLogCollection =
          FirebaseFirestore.instance.collection('activity_log');

      await activityLogCollection.add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'productId': productId,
        'productName': productName,
        'productData': productData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording activity log: $e');
    }
  }

  // Fungsi untuk menghitung jumlah produk per kategori
  Future<void> getProductCountByCategory(
      void Function(int totalProduk, int makananCount, int minumanCount)
          callback) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _produkCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      int totalProduk = 0;
      int makananCount = 0;
      int minumanCount = 0;

      snapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> document) {
        String? category = document.data()?['kategori'];
        if (category != null) {
          totalProduk++;
          if (category == 'Makanan') {
            makananCount++;
          } else if (category == 'Minuman') {
            minumanCount++;
          }
        }
      });

      callback(totalProduk, makananCount, minumanCount);
    } catch (error) {
      print("Error getting product count by category: $error");
      throw error;
    }
  }

// Fungsi untuk mendapatkan foto profil pengguna berdasarkan peran (role staf)
  Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
    try {
      final QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> userProfiles = [];

      userSnapshot.docs.forEach((userDoc) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Pastikan properti yang diperlukan tersedia dan tidak null
        if (userData.containsKey('displayName') &&
            userData.containsKey('email') &&
            userData.containsKey('role')) {
          String displayName = userData['displayName'] ?? '';
          String email = userData['email'] ?? '';
          String role = userData['role'] ?? '';

          // Tambahkan user ke userProfiles jika memiliki role 'admin' atau 'staf'
          if (role == 'admin' || role == 'staf') {
            // Dapatkan nilai photoUrl dan whatsapp jika tersedia, atau gunakan default value jika null
            String photoUrl = userData['photoUrl'] ?? '';
            String whatsapp = userData['whatsapp'] ?? '';

            userProfiles.add({
              'displayName': displayName,
              'email': email,
              'photoUrl': photoUrl,
              'whatsapp': whatsapp,
              'role': role,
            });
          }
        }
      });

      return userProfiles;
    } catch (e) {
      print('Error getting user profiles: $e');
      return [];
    }
  }

  // EDIT PRODUK
}
