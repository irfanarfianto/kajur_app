import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/utils/animation/route/slide_left.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:kajur_app/screens/keuangan/keuangan.dart';
import 'package:kajur_app/components/user/user_name.dart';
import 'package:kajur_app/screens/notifications/notifications_page.dart';
import 'package:kajur_app/screens/user/profile_page.dart';
import 'package:kajur_app/utils/internet_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;
  String _userRole = '';
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();

    _refreshData();
  }

  Future<void> _refreshData() async {
    try {
      while (await checkInternetConnection() == false) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Simulasi pengambilan data baru dari sumber data Anda
      await Future.delayed(const Duration(seconds: 3));
    } catch (error) {
      showToast(
        message: 'Terjadi kesalahan: $error',
      );
    }
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (currentBackPressTime == null ||
            DateTime.now().difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          // Jika pengguna menekan tombol kembali untuk pertama kalinya
          currentBackPressTime = DateTime.now();
          showToast(message: "Tekan kembali sekali lagi untuk keluar");
          return false;
        } else {
          return true;
        }
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: true),
        child: Scaffold(
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser?.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Col.whiteColor,
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const Text('No Data');
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              _userRole = userData['role'] ?? 'biasa';

              return NestedScrollView(
                physics: const ClampingScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      surfaceTintColor: Col.backgroundColor,
                      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Col.backgroundColor,
                      ),
                      elevation: 2,
                      backgroundColor: Col.backgroundColor,
                      automaticallyImplyLeading: false,
                      leadingWidth: double.infinity,
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              SlideLeftRoute(
                                  page: UserProfilePage(
                                      currentUser: _currentUser)));
                        },
                        child: buildUserWidget(context, _currentUser),
                      ),
                      actions: [
                        Skeleton.keep(
                          child: IconButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            color: Col.greyColor,
                            iconSize: 24,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  SlideLeftRoute(
                                    page: const NotificationPage(),
                                  ));
                            },
                            icon: const Icon(Icons.notifications_none_outlined),
                          ),
                        ),
                      ],
                      floating: true,
                      snap: true,
                    ),
                  ];
                },
                body: KeuanganContent(
                  userRole: _userRole,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
