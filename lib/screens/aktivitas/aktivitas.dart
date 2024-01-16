import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kajur_app/design/system.dart';

enum SortOrder { Terbaru, Terlama }

enum FilterOrder { Hapus, Tambah, Edit }

class AllActivitiesPage extends StatefulWidget {
  @override
  State<AllActivitiesPage> createState() => _AllActivitiesPageState();
}

class _AllActivitiesPageState extends State<AllActivitiesPage> {
  bool _enabled = true;
  SortOrder _currentSortOrder = SortOrder.Terbaru;
  FilterOrder _currentFilterOrder = FilterOrder.Edit;
  // DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _toggleSortOrder() {
    setState(() {
      _currentSortOrder = _currentSortOrder == SortOrder.Terbaru
          ? SortOrder.Terlama
          : SortOrder.Terbaru;
      _refreshData();
    });
  }

  void _toggleFilterOrder() {
    setState(() {
      _currentFilterOrder = _currentFilterOrder == FilterOrder.Hapus
          ? FilterOrder.Tambah
          : FilterOrder.Edit;
      _refreshData();
    });
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

  List<Map<String, dynamic>> _activitiesData = [];

  Future<void> _refreshData() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('activity_log')
          .orderBy('timestamp',
              descending: _currentSortOrder == SortOrder.Terbaru)
          .get();

      setState(() {
        _activitiesData.clear();
        querySnapshot.docs.forEach((DocumentSnapshot doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _activitiesData.add(data);
        });
      });
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
                      Text(
                        'Urutkan berdasarkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        activeColor: DesignSystem.primaryColor,
                        title: Text(
                          'Terbaru',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                            onPrimary: DesignSystem.greyColor),
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

  // void _showFilterOptions(BuildContext context) {
  //   bool isSelectedHapus = _currentFilterOrder == FilterOrder.Hapus;
  //   bool isSelectedTambah = _currentFilterOrder == FilterOrder.Tambah;
  //   bool isSelectedEdit = _currentFilterOrder == FilterOrder.Edit;
  //   DateTimeRange? pickedDateRange = _selectedDateRange;

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //             ),
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Container(
  //                   height: 5,
  //                   width: 40,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(100),
  //                     color: DesignSystem.greyColor.withOpacity(.50),
  //                   ),
  //                 ),
  //                 SizedBox(height: 16),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Filter',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     SizedBox(height: 16),
  //                     ElevatedButton(
  //                       onPressed: () async {
  //                         // Show date range picker
  //                         DateTimeRange? picked = await showDateRangePicker(
  //                           context: context,
  //                           firstDate: DateTime(2000),
  //                           lastDate: DateTime(2101),
  //                           initialDateRange: pickedDateRange,
  //                         );

  //                         // Update selected date range
  //                         if (picked != null && picked != pickedDateRange) {
  //                           setState(() {
  //                             pickedDateRange = picked;
  //                           });
  //                         }
  //                       },
  //                       child: Text(
  //                         'Pilih Rentang Tanggal',
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                     SizedBox(height: 16),
  //                     CheckboxListTile(
  //                       activeColor: DesignSystem.primaryColor,
  //                       title: Text(
  //                         'Hapus Produk',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       value: isSelectedHapus,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           isSelectedHapus = value!;
  //                           isSelectedTambah = false;
  //                           isSelectedEdit = false;
  //                         });
  //                       },
  //                     ),
  //                     CheckboxListTile(
  //                       activeColor: DesignSystem.primaryColor,
  //                       title: Text(
  //                         'Tambah Produk',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       value: isSelectedTambah,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           isSelectedTambah = value!;
  //                           isSelectedHapus = false;
  //                           isSelectedEdit = false;
  //                         });
  //                       },
  //                     ),
  //                     CheckboxListTile(
  //                       activeColor: DesignSystem.primaryColor,
  //                       title: Text(
  //                         'Edit Produk',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       value: isSelectedEdit,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           isSelectedEdit = value!;
  //                           isSelectedHapus = false;
  //                           isSelectedTambah = false;
  //                         });
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     TextButton(
  //                       style: ElevatedButton.styleFrom(
  //                           primary: Colors.transparent,
  //                           onPrimary: DesignSystem.greyColor),
  //                       onPressed: () {
  //                         // Reset Filters
  //                         setState(() {
  //                           isSelectedHapus = false;
  //                           isSelectedTambah = false;
  //                           isSelectedEdit = false;
  //                           pickedDateRange = null;
  //                         });
  //                       },
  //                       child: Text('Reset'),
  //                     ),
  //                     SizedBox(width: 16),
  //                     Expanded(
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           if (isSelectedHapus) {
  //                             _currentFilterOrder = FilterOrder.Hapus;
  //                           } else if (isSelectedTambah) {
  //                             _currentFilterOrder = FilterOrder.Tambah;
  //                           } else if (isSelectedEdit) {
  //                             _currentFilterOrder = FilterOrder.Edit;
  //                           }
  //                           _selectedDateRange = pickedDateRange;
  //                           _refreshData();
  //                           Navigator.pop(context);
  //                         },
  //                         child: Text('Pilih filter'),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // shadowColor: DesignSystem.greyColor,
        elevation: 5,
        scrolledUnderElevation: 3,
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
              child: ListView.builder(
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
                                fontSize: 18,
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
                              color:
                                  _getActionIconBackgroundColor(data['action']),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
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
              ),
            )),
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
