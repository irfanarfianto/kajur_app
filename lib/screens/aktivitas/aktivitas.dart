import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/screens/aktivitas/detail_activity.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:kajur_app/utils/internet_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kajur_app/design/system.dart';
import 'package:collection/collection.dart';

enum SortOrder { Terbaru, Terlama }

class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  final SortOrder _currentSortOrder = SortOrder.Terbaru;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      while (await checkInternetConnection() == false) {
        // Tunggu 2 detik sebelum memeriksa koneksi lagi
        await Future.delayed(const Duration(seconds: 2));
      }
      await Future.delayed(const Duration(seconds: 2));
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        backgroundColor: Col.backgroundColor,
        body: NestedScrollView(
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Col.primaryColor,
                  statusBarIconBrightness: Brightness.light,
                ),
                elevation: 2,
                backgroundColor: Col.primaryColor,
                foregroundColor: Col.whiteColor,
                floating: true,
                snap: true,
                title: const Text('Semua Aktivitas'),
              ),
            ];
          },
          body: RefreshIndicator(
            color: Col.primaryColor,
            backgroundColor: Col.secondaryColor,
            onRefresh: _refreshData,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Skeleton.keep(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EasyDateTimeLine(
                      locale: "id",
                      initialDate: DateTime.now(),
                      onDateChange: (selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      },
                      activeColor: Col.primaryColor,
                      dayProps: const EasyDayProps(
                        height: 70,
                        activeBorderRadius: 15,
                        inactiveBorderRadius: 15,
                        dayStructure: DayStructure.dayStrDayNum,
                        todayHighlightStyle: TodayHighlightStyle.withBorder,
                        todayHighlightColor: Col.primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('activity_log')
                        .where('timestamp',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day)),
                            isLessThan: Timestamp.fromDate(DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day + 1)))
                        .orderBy('timestamp',
                            descending: _currentSortOrder == SortOrder.Terbaru)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: List.generate(
                            3,
                            (index) => Skeletonizer(
                              enabled: true,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  ListTile(
                                    leading: Skeleton.leaf(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(28),
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
                                  if (index <
                                      2) // Don't add Divider after the last item
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

                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/NotEmpty.png',
                                width: 200,
                                height: 200,
                              ),
                              const Text(
                                'Oops, nggak ada update\nditanggal segitu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      List<Map<String, dynamic>> activitiesData =
                          snapshot.data!.docs.map((DocumentSnapshot doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        data['id'] = doc
                            .id; // Menyertakan ID dokumen ke dalam data aktivitas
                        return data;
                      }).toList();

                      Map<String, List<Map<String, dynamic>>>
                          groupedActivities = groupBy(
                              activitiesData,
                              (Map<String, dynamic> activity) =>
                                  DateFormat('dd MMMM y', 'id').format(
                                      (activity['timestamp'] as Timestamp)
                                          .toDate()));

                      return Stack(
                        children: [
                          ListView.builder(
                            itemCount: groupedActivities.length,
                            itemBuilder: (BuildContext context, int index) {
                              String date =
                                  groupedActivities.keys.toList()[index];
                              List<Map<String, dynamic>> activities =
                                  groupedActivities[date]!;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Col.secondaryColor,
                                        border: Border.all(
                                            color: const Color(0x309E9E9E),
                                            width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Col.greyColor.withOpacity(.10),
                                            offset: const Offset(0, 5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: activities.length,
                                        itemBuilder: (BuildContext context,
                                            int activityIndex) {
                                          Map<String, dynamic> data =
                                              activities[activityIndex];

                                          return Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation,
                                                              secondaryAnimation) =>
                                                          ActivityDetailPage(
                                                              activityData:
                                                                  data),
                                                      transitionsBuilder:
                                                          (context,
                                                              animation,
                                                              secondaryAnimation,
                                                              child) {
                                                        const begin =
                                                            Offset(0.0, 0.3);
                                                        const end = Offset.zero;
                                                        const curve =
                                                            Curves.easeOutCubic;

                                                        var tween = Tween(
                                                                begin: begin,
                                                                end: end)
                                                            .chain(
                                                          CurveTween(
                                                              curve: curve),
                                                        );

                                                        var offsetAnimation =
                                                            animation
                                                                .drive(tween);

                                                        return SlideTransition(
                                                          position:
                                                              offsetAnimation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                leading: Skeleton.leaf(
                                                  child: ActivityIcon(
                                                      action: data['action']),
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                        (data['action'] ?? '') +
                                                            (data['productName'] !=
                                                                    null
                                                                ? ' - ${data['productName']}'
                                                                : ''),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Typo
                                                            .emphasizedBodyTextStyle,
                                                      ),
                                                    ),
                                                    Text(
                                                      (data['timestamp'] != null
                                                          ? DateFormat(
                                                                  ' HH:mm ',
                                                                  'id')
                                                              .format((data[
                                                                          'timestamp']
                                                                      as Timestamp)
                                                                  .toDate())
                                                          : 'Timestamp tidak tersedia'),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Text(
                                                  (data['userName'] ?? ''),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (activityIndex <
                                                  activities.length - 1)
                                                Divider(
                                                  thickness: 1,
                                                  color: Col.greyColor
                                                      .withOpacity(0.2),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 80)
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              // gradien
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [
                                    0.0,
                                    1.0
                                  ],
                                      colors: [
                                    Col.secondaryColor.withOpacity(0.1),
                                    Col.secondaryColor,
                                  ])),
                              height: 50,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
