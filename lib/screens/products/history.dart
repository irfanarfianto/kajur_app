import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/design/system.dart';

class ActivityHistoryPage extends StatefulWidget {
  @override
  _ActivityHistoryPageState createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  late Stream<QuerySnapshot> _activityStream;

  @override
  void initState() {
    super.initState();
    _activityStream = FirebaseFirestore.instance
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _activityStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No activity logs available',
                    style: TextStyle(color: DesignSystem.whiteColor)));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> logData =
                  document.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                  logData['action'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Timestamp: ${logData['timestamp'].toDate().toString()}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
