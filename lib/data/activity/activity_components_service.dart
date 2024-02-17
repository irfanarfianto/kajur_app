import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityWidgetService {
  final CollectionReference _activityWidget =
      FirebaseFirestore.instance.collection('activity_log');

  Stream<QuerySnapshot> getActivityWidget() {
    return _activityWidget
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }
}
