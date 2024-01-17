import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kajur_app/design/system.dart';

enum SortOrder { Terbaru, Terlama }

// enum FilterOrder { Hapus, Tambah, Edit }

class AllActivitiesPage extends StatefulWidget {
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
      await Future.delayed(Duration(seconds: 2));
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      if (mounted) {
        setState(() {
          _enabled = false;
        });
      }
    }
  }

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

  void _showSortOptions(BuildContext context) {
    bool isSelectedTerbaru = _currentSortOrder == SortOrder.Terbaru;
    bool isSelectedTerlama = _currentSortOrder == SortOrder.Terlama;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                color: DesignSystem.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: DesignSystem.greyColor.withOpacity(.50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urutkan', style: DesignSystem.titleTextStyle),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        activeColor: DesignSystem.primaryColor,
                        title: Text(
                          'Terbaru',
                          style: DesignSystem.subtitleTextStyle,
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
                        activeColor: DesignSystem.primaryColor,
                        title: Text(
                          'Terlama',
                          style: DesignSystem.subtitleTextStyle,
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: DesignSystem.greyColor,
                        ),
                        onPressed: () {
                          // Reset Filters
                          setState(() {
                            isSelectedTerbaru = false;
                            isSelectedTerlama = false;
                          });
                        },
                        child: Text('Reset'),
                      ),
                      SizedBox(width: 16),
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
                          child: Text('Pilih filter'),
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
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        surfaceTintColor: DesignSystem.backgroundColor,
        title: Text('Semua Aktivitas'),
      ),
      body: Scrollbar(
        child: RefreshIndicator(
          color: DesignSystem.primaryColor,
          backgroundColor: DesignSystem.backgroundColor,
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: DesignSystem.primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                List<Map<String, dynamic>> _activitiesData =
                    snapshot.data!.docs.map((DocumentSnapshot doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return data;
                }).toList();

                return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: _activitiesData.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> data = _activitiesData[index];

                    DateTime activityDate =
                        (data['timestamp'] as Timestamp).toDate();

                    String formattedDate =
                        DateFormat('dd MMMM y', 'id').format(activityDate);

                    bool isFirstActivityWithDate = index == 0 ||
                        formattedDate !=
                            DateFormat('dd MMMM y', 'id').format(
                                (_activitiesData[index - 1]['timestamp']
                                        as Timestamp)
                                    .toDate());

                    return Column(
                      children: [
                        if (isFirstActivityWithDate)
                          Container(
                            alignment: Alignment.centerLeft,
                            width: double.infinity,
                            color: DesignSystem.greyColor.withOpacity(.10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: DesignSystem.blackColor,
                                ),
                              ),
                            ),
                          ),
                        ListTile(
                          leading: Skeleton.leaf(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getActionIconBackgroundColor(
                                    data['action']),
                              ),
                              child: _getActionIcon(data['action']),
                            ),
                          ),
                          title: Flexible(
                            child: Text(
                              (data['action'] ?? '') +
                                  (data['productName'] != null
                                      ? ' - ${data['productName']}'
                                      : ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DesignSystem.emphasizedBodyTextStyle,
                            ),
                          ),
                          subtitle: Text(
                            (data['userName'] ?? '') +
                                ' pada ' +
                                (data['timestamp'] != null
                                    ? DateFormat('dd MMMM y • HH:mm ', 'id')
                                        .format((data['timestamp'] as Timestamp)
                                            .toDate())
                                    : 'Timestamp tidak tersedia'),
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            color: DesignSystem.greyColor.withOpacity(.10),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60, // Set the desired height here
        child: BottomAppBar(
          color: DesignSystem.whiteColor,
          shape: CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  primary: DesignSystem.primaryColor,
                ),
                label: Text(
                    'Urutkan "${_currentSortOrder == SortOrder.Terbaru ? 'Terbaru' : 'Terlama'}"'),
                icon: Icon(Icons.sort_outlined),
                onPressed: () {
                  _showSortOptions(context);
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  primary: DesignSystem.primaryColor,
                ),
                label: Text('Filter'),
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  // _showFilterOptions(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
