// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kajur_app/design/system.dart';

import 'package:kajur_app/screens/home/widget/activity_widget.dart';
import 'package:kajur_app/screens/home/widget/drawer_widget.dart';
import 'package:kajur_app/screens/home/widget/stock_widget.dart';
import 'package:kajur_app/screens/home/widget/total_produk_widget.dart';
import 'package:kajur_app/screens/menu_button.dart';

import 'package:flutter/services.dart';

import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;

  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchTotalProducts();
    _refreshData();
  }

  Future<void> _fetchTotalProducts() async {
    int total = await getTotalProducts();
    setState(() {
      totalProducts = total;
    });
  }

  Future<int> getTotalProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('kantin').get();

      return querySnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _enabled = true;
      });

      // Simulate fetching new data from your data source
      await Future.delayed(const Duration(seconds: 2));

      // After fetching new data, you can setState or update your variables
      // Example: setState(() { yourData = fetchedData; });
    } catch (error) {
      // Handle error if it occurs during data refresh
    } finally {
      setState(() {
        _enabled = false;
      });
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title:
          const Text("Manajemen Kajur", style: TextStyle(fontFamily: 'Roboto')),
      actions: [
        // notification icon
        IconButton(
            onPressed: () {
              // TODO: implement notification icon
              Navigator.pushNamed(context, '/comingsoon');
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
            ))
      ],
    );
  }

  void _confirmSignOut() {
    // Your sign-out logic here
    // Example:
    // _googleSignIn.signOut();
    // FirebaseAuth.instance.signOut();
    // Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    // showToast(message: "Berhasil keluar");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(),
        ),
        endDrawer: Drawer(
          child: DrawerWidget(
            currentUser: _currentUser,
            confirmSignOut: _confirmSignOut,
          ),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              color: DesignSystem.primaryColor,
              onRefresh: _refreshData,
              child: Skeletonizer(
                enabled: _enabled,
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [
                      buildTotalProductsWidget(context),
                      buildStockWidget(context),
                      RecentActivityWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const MenuButton();
                },
              );
            },
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: DesignSystem.primaryColor,
            foregroundColor: DesignSystem.whiteColor,
            icon: const Icon(Icons.rocket_launch_outlined),
            label: const Text('Menu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ))),
      ),
    );
  }
}
