// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kajur_app/design/system.dart';

import 'package:kajur_app/screens/aktivitas/activity_widget.dart';

import 'package:kajur_app/screens/home/widget/stock_widget.dart';
import 'package:kajur_app/screens/home/widget/total_produk_widget.dart';
import 'package:kajur_app/screens/menu_button.dart';

import 'package:flutter/services.dart';
import 'package:kajur_app/screens/user/profile.dart';

import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: DesignSystem.backgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  UserProfilePage(currentUser: _currentUser),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

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
        child: _buildUserWidget(_currentUser),
      ),
      actions: [
        // notification icon
        IconButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          color: DesignSystem.greyColor,
          iconSize: 24,
          constraints: const BoxConstraints(),
          onPressed: () {
            // TODO: implement notification icon
            Navigator.pushNamed(context, '/comingsoon');
          },
          icon: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    );
  }

  Widget _buildUserWidget(User? currentUser) {
    if (_currentUser == null) {
      return const CircularProgressIndicator(
        color: DesignSystem.whiteColor,
      );
    } else {
      return Container(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('images/avatar.png'),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_currentUser!.displayName}",
                  style: const TextStyle(
                    fontWeight: DesignSystem.regular,
                    fontSize: 18,
                    color: DesignSystem.blackColor,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      color: DesignSystem.greyColor,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${_currentUser!.email}",
                      style: const TextStyle(
                        color: DesignSystem.greyColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );
    }
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
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: _buildAppBar(context),
          ),
          body: RefreshIndicator(
            color: DesignSystem.primaryColor,
            onRefresh: _refreshData,
            child: Skeletonizer(
              enabled: _enabled,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    buildTotalProductsWidget(context),
                    buildStockWidget(context),
                    const RecentActivityWidget(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
      ),
    );
  }
}
