import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/data/activity/activity_components_service.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/aktivitas_page.dart';
import 'package:kajur_app/components/activity/detail_activity.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:kajur_app/screens/widget/catergory_icon.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildRecentActivityWidget(context) {
  final ActivityWidgetService activityWidgetService = ActivityWidgetService();

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Col.secondaryColor,
      border: Border.all(color: const Color(0x309E9E9E), width: 1),
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
                TextButton(
                  child: const Text(
                    'Lihat semua',
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
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
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: activityWidgetService.getActivityWidget(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: List.generate(
                  4,
                  (index) => Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Skeleton.leaf(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                          title: Container(
                            width: 200,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          subtitle: Container(
                            width: 100,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.grey[300],
                                size: 15,
                              ),
                              Container(
                                width: 60,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                        if (index < 2) // Don't add Divider after the last item
                          Divider(
                            thickness: 1,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
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

                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                final currencyFormat = NumberFormat.currency(
                    locale: 'id', symbol: 'Rp ', decimalDigits: 0);
                final amount = data['amount'];

                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ActivityDetailPage(activityData: data),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(0.0, 0.3);
                              const end = Offset.zero;
                              const curve = Curves.easeOutCubic;

                              var tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );

                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      leading: Skeleton.leaf(
                        child: ActivityIcon(action: data['action']),
                      ),
                      title: SizedBox(
                        width: 200,
                        child: Text(
                          (data['action'] ?? '') +
                              (data['productName'] != null
                                  ? ' - ${data['productName']}'
                                  : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Typo.emphasizedBodyTextStyle,
                        ),
                      ),
                      subtitle: Text(
                        (data['userName'] ?? ''),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 100,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data['action'] == 'Pengeluaran'
                                  ? '-${currencyFormat.format(amount)}' // Tambahkan tanda negatif di sini
                                  : (amount != null
                                      ? currencyFormat.format(amount)
                                      : ''),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: data['action'] == 'Pengeluaran'
                                    ? Col.redAccent
                                    : Col.greenAccent,
                              ),
                            ),
                            if (data['category'] != null)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: CarouselSlider(
                                    disableGesture: true,
                                    items: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            data['category'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          CategoryIcon(
                                            category: data['category'],
                                          ),
                                        ],
                                      ),
                                      if (data['timestamp'] != null)
                                        Text(
                                          DateFormat(' HH:mm WIB', 'id').format(
                                              (data['timestamp'] as Timestamp)
                                                  .toDate()),
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                    options: CarouselOptions(
                                      viewportFraction: 1,
                                      aspectRatio: 2 / 1.5,
                                      height: 16,
                                      autoPlayInterval:
                                          const Duration(seconds: 8),
                                      autoPlay: true,
                                      scrollDirection: Axis.vertical,
                                    ),
                                  ),
                                ),
                              ),
                            if (data['category'] == null &&
                                data['timestamp'] != null)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  DateFormat(' HH:mm WIB', 'id').format(
                                      (data['timestamp'] as Timestamp)
                                          .toDate()),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (index < snapshot.data!.docs.length - 1)
                      Divider(
                        thickness: 1,
                        color: Col.greyColor.withOpacity(0.2),
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
