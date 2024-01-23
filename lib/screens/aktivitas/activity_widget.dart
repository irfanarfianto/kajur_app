import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton.keep(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aktivitas Terbaru',
                        style: DesignSystem.titleTextStyle,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AllActivitiesPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

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
                        child: const Row(
                          children: [
                            Text(
                              "Lihat semua",
                              style: DesignSystem.bodyTextStyle,
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.east,
                              color: DesignSystem.blackColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activity_log')
                      .orderBy('timestamp', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: DesignSystem.primaryColor,
                          ),
                        ),
                      );
                    }

                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada aktivitas terbaru'),
                      );
                    }

                    // Use ListView.builder instead of ListView
                    return Column(
                      children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: DesignSystem.secondaryColor,
                            border: Border.all(
                                color: DesignSystem.greyColor.withOpacity(.10)),
                            boxShadow: [
                              BoxShadow(
                                color: DesignSystem.greyColor.withOpacity(.10),
                                offset: const Offset(0, 5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Skeleton.leaf(
                                    child:
                                        ActivityIcon(action: data['action'])),
                                title: Text(
                                  (data['action'] ?? '') +
                                      (data['productName'] != null
                                          ? ' - ${data['productName']}'
                                          : ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: DesignSystem.emphasizedBodyTextStyle,
                                ),
                                subtitle: Text(
                                  (data['userName'] ?? '') +
                                      ' pada ' +
                                      (data['timestamp'] != null
                                          ? DateFormat(
                                                  'dd MMMM y • HH:mm ', 'id')
                                              .format((data['timestamp']
                                                      as Timestamp)
                                                  .toDate())
                                          : 'Timestamp tidak tersedia'),
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
