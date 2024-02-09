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

// enum FilterOrder { Hapus, Tambah, Edit }

class AllActivitiesPage extends StatefulWidget {
  const AllActivitiesPage({super.key});

  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  bool _enabled = true;
  SortOrder _currentSortOrder = SortOrder.Terbaru;
  // FilterOrder _currentFilterOrder = FilterOrder.Edit;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = true;
    });

    try {
      while (await checkInternetConnection() == false) {
        // Tunggu 2 detik sebelum memeriksa koneksi lagi
        await Future.delayed(const Duration(seconds: 2));
      }
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) {
        setState(() {
          _enabled = false;
        });
      }
    }
  }

  void _showSortOptions(BuildContext context) {
    bool isSelectedTerbaru = _currentSortOrder == SortOrder.Terbaru;
    bool isSelectedTerlama = _currentSortOrder == SortOrder.Terlama;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Col.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Col.greyColor.withOpacity(.50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urutkan', style: Typo.titleTextStyle),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        activeColor: Col.primaryColor,
                        title: const Text(
                          'Terbaru',
                          style: Typo.subtitleTextStyle,
                        ),
                        value: isSelectedTerbaru,
                        onChanged: (value) {
                          setState(() {
                            isSelectedTerbaru = value!;
                            isSelectedTerlama = !value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        activeColor: Col.primaryColor,
                        title: const Text(
                          'Terlama',
                          style: Typo.subtitleTextStyle,
                        ),
                        value: isSelectedTerlama,
                        onChanged: (value) {
                          setState(() {
                            isSelectedTerlama = value!;
                            isSelectedTerbaru = !value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Col.greyColor,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          // Reset Filters
                          setState(() {
                            isSelectedTerbaru = false;
                            isSelectedTerlama = false;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply Filters
                            if (isSelectedTerbaru) {
                              _currentSortOrder = SortOrder.Terbaru;
                            } else if (isSelectedTerlama) {
                              _currentSortOrder = SortOrder.Terlama;
                            }
                            _refreshData();
                            Navigator.pop(context);
                          },
                          child: const Text('Pilih filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            child: Skeletonizer(
              enabled: _enabled,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('activity_log')
                    .orderBy('timestamp',
                        descending: _currentSortOrder == SortOrder.Terbaru)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
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

                  Map<String, List<Map<String, dynamic>>> groupedActivities =
                      groupBy(
                          activitiesData,
                          (Map<String, dynamic> activity) =>
                              DateFormat('dd MMMM y', 'id').format(
                                  (activity['timestamp'] as Timestamp)
                                      .toDate()));

                  return ListView.builder(
                    itemCount: groupedActivities.length,
                    itemBuilder: (BuildContext context, int index) {
                      String date = groupedActivities.keys.toList()[index];
                      List<Map<String, dynamic>> activities =
                          groupedActivities[date]!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(date, style: Typo.titleTextStyle),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Col.secondaryColor,
                                border: Border.all(
                                    color: const Color(0x309E9E9E), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Col.greyColor.withOpacity(.10),
                                    offset: const Offset(0, 5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: activities.length,
                                itemBuilder:
                                    (BuildContext context, int activityIndex) {
                                  Map<String, dynamic> data =
                                      activities[activityIndex];

                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ActivityDetailPage(
                                                      activityData: data),
                                            ),
                                          );
                                        },
                                        leading: Skeleton.leaf(
                                          child: ActivityIcon(
                                              action: data['action']),
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                (data['action'] ?? '') +
                                                    (data['productName'] != null
                                                        ? ' - ${data['productName']}'
                                                        : ''),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Typo
                                                    .emphasizedBodyTextStyle,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.history,
                                                    color: Col.greyColor,
                                                    size: 15),
                                                Text(
                                                  (data['timestamp'] != null
                                                      ? DateFormat(
                                                              ' HH:mm ', 'id')
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
                                          ],
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
                                      ),
                                      if (activityIndex < activities.length - 1)
                                        Divider(
                                          thickness: 1,
                                          color: Col.greyColor.withOpacity(0.2),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 60, // Set the desired height here
          child: BottomAppBar(
            color: Col.whiteColor,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Col.primaryColor,
                  ),
                  label: Text(
                      'Urutkan "${_currentSortOrder == SortOrder.Terbaru ? 'Terbaru' : 'Terlama'}"'),
                  icon: const Icon(Icons.sort_outlined),
                  onPressed: () {
                    _showSortOptions(context);
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Col.primaryColor,
                  ),
                  label: const Text('Filter'),
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // _showFilterOptions(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
