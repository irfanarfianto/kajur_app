import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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


  // EDIT PRODUK
  
}
