import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/screens/aktivitas/detail_activity.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:kajur_app/screens/widget/icon_text_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Col.secondaryColor,
        border: Border.all(color: Col.greyColor.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Col.greyColor.withOpacity(.10),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton.keep(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktivitas Terbaru',
                    style: Typo.titleTextStyle,
                  ),
                  IconTextButton(
                    text: 'Lihat semua',
                    iconData: Icons.east,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AllActivitiesPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 0.5);
                            const end = Offset.zero;
                            const curve = Curves.linearToEaseOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    iconOnRight: true,
                    iconColor: Col.greyColor,
                    textColor: Col.greyColor,
                    iconSize: 15.0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activity_log')
                .orderBy('timestamp', descending: true)
                .limit(3)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Col.primaryColor,
                    ),
                  ),
                );
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Tidak ada aktivitas terbaru'),
                );
              }

              return Column(
                children: snapshot.data!.docs.asMap().entries.map((entry) {
                  int index = entry.key;
                  DocumentSnapshot doc = entry.value;

                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  data['id'] =
                      doc.id; // Menyertakan ID dokumen ke dalam data aktivitas

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigasi ke halaman detail dan kirimkan data aktivitas
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ActivityDetailPage(activityData: data),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Skeleton.leaf(
                                child: ActivityIcon(action: data['action']),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (data['action'] ?? '') +
                                          (data['productName'] != null
                                              ? ' - ${data['productName']}'
                                              : ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Typo.emphasizedBodyTextStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (data['userName'] ?? ''),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              (data['timestamp'] != null
                                                  ? DateFormat(' HH:mm ', 'id')
                                                      .format((data['timestamp']
                                                              as Timestamp)
                                                          .toDate())
                                                  : 'Timestamp tidak tersedia'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const Icon(Icons.history,
                                                color: Col.greyColor, size: 15),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < snapshot.data!.docs.length - 1)
                        Divider(
                          thickness: 1,
                          color: Col.greyColor.withOpacity(0.1),
                        ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
