import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/notifications/notifications_page.dart';
import 'package:kajur_app/screens/aktivitas/components/activity_widget.dart';
import 'package:kajur_app/screens/home/component/menu.dart';
import 'package:kajur_app/screens/home/component/total_produk_widget.dart';
import 'package:kajur_app/screens/user/profile.dart';
import 'package:kajur_app/utils/internet_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? _currentUser;
  int totalProducts = 0;
  String _userRole = '';

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
      while (await checkInternetConnection() == false) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Simulasi pengambilan data baru dari sumber data Anda
      await Future.delayed(const Duration(seconds: 3));
    } catch (error) {}
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Widget _buildUserWidget(User? currentUser) {
    if (currentUser == null) {
      return const CircularProgressIndicator(
        color: Col.whiteColor,
      );
    } else {
      // Mendapatkan waktu sekarang
      var now = DateTime.now();
      var greeting = '';

      // Menentukan ucapan berdasarkan waktu
      if (now.hour < 11) {
        greeting = '🌞 Selamat Pagi';
      } else if (now.hour < 15) {
        greeting = '☀️ Selamat Siang';
      } else if (now.hour < 19) {
        greeting = '☀️ Selamat Sore';
      } else {
        greeting = '🌚 Selamat Malam';
      }

      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
          var role = userData['role'] ?? 'biasa';
          var photoUrl = userData['photoUrl'];

          return Skeleton.keep(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: currentUser.uid,
                  child: CircleAvatar(
                    backgroundImage: photoUrl != null
                        ? CachedNetworkImageProvider(photoUrl)
                        : null,
                    radius: 20,
                    child: photoUrl == null
                        ? const Icon(
                            Icons.account_circle,
                            size: 20,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CarouselSlider(
                        items: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              color: Col.blackColor,
                              fontSize: 12,
                              fontWeight: Fw.regular,
                            ),
                          ),
                          Text(
                            role.substring(0, 1).toUpperCase() +
                                role.substring(1),
                            style: const TextStyle(
                              color: Col.blackColor,
                              fontSize: 12,
                              fontWeight: Fw.regular,
                            ),
                          ),
                        ],
                        options: CarouselOptions(
                          viewportFraction: 1,
                          aspectRatio: 2 / 1.5,
                          height: 20,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlay: true,
                          scrollDirection: Axis.vertical,
                        ),
                      ),
                      Text(
                        currentUser.displayName ?? '',
                        style: Typo.titleTextStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser?.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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

          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: true),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
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
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  UserProfilePage(currentUser: _currentUser),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.5, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.linearToEaseOut;

                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            return SlideTransition(
                              position: animation.drive(tween),
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
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const NotificationPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(0.5, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.linearToEaseOut;

                                var tween = Tween(begin: begin, end: end).chain(
                                  CurveTween(curve: curve),
                                );

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_none_outlined),
                      ),
                    ),
                  ],
                  floating: true,
                  snap: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          buildTotalProductsWidget(context),
                          const SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                 buildMenuWidget(context, _userRole),
                                const SizedBox(height: 20),
                                buildRecentActivityWidget(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Skeleton.keep(
                        child: Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text('~ Segini dulu yaa ~',
                                  style: Typo.subtitleTextStyle),
                              Image.asset(
                                'images/gambar.png',
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
