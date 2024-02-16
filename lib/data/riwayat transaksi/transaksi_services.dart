import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final CollectionReference _transactionCollection =
      FirebaseFirestore.instance.collection('transaction_history');

  Stream<QuerySnapshot> getTransactions() {
    return _transactionCollection
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }
}
