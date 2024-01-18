import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Center(
            child: Container(
              height: 335,
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: DesignSystem.secondaryColor,
                border: Border.all(
                  color: DesignSystem.greyColor.withOpacity(.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.greyColor.withOpacity(.10),
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 5),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activity_log')
                        .orderBy('timestamp', descending: true)
                        .limit(3)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: DesignSystem.primaryColor,
                          ),
                        );
                      }

                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada aktivitas terbaru'),
                        );
                      }

                      // Use ListView.builder instead of ListView
                      return Column(
                        children:
                            snapshot.data!.docs.map((DocumentSnapshot doc) {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;

                          return Column(
                            children: [
                              ListTile(
                                leading: ActivityIcon(action: data['action']),
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
                              Divider(
                                color: DesignSystem.greyColor.withOpacity(.10),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan ikon berdasarkan nilai action
  Icon _getActionIcon(String? action) {
    IconData iconData;
    Color iconColor;

    switch (action) {
      case 'Tambah Produk':
        iconData = Icons.add;
        iconColor = Colors.green;
        break;
      case 'Edit Produk':
        iconData = Icons.edit;
        iconColor = Colors.orange;
        break;
      case 'Hapus Produk':
        iconData = Icons.delete;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
    );
  }

  // Fungsi untuk mendapatkan warna latar belakang ikon berdasarkan nilai action
  Color _getActionIconBackgroundColor(String? action) {
    Color backgroundColor;

    switch (action) {
      case 'Tambah Produk':
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'Edit Produk':
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'Hapus Produk':
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return backgroundColor;
  }
}
