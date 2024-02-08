// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:kajur_app/design/system.dart';

import 'package:kajur_app/screens/aktivitas/components/activity_widget.dart';
import 'package:kajur_app/screens/home/component/menu.dart';

import 'package:kajur_app/screens/home/component/total_produk_widget.dart';

import 'package:flutter/services.dart';
import 'package:kajur_app/screens/user/profile.dart';
import 'package:kajur_app/utils/internet_utils.dart';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

      while (await checkInternetConnection() == false) {
        // Tunggu 2 detik sebelum memeriksa koneksi lagi
        await Future.delayed(const Duration(seconds: 2));
      }

      // Simulasi pengambilan data baru dari sumber data Anda
      await Future.delayed(const Duration(seconds: 2));

      // Setelah mengambil data baru, Anda dapat memanggil setState atau memperbarui variabel
      // Contoh: setState(() { yourData = fetchedData; });
    } catch (error) {
      // Tangani kesalahan jika terjadi selama pembaruan data
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
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    radius: 20,
                    child: photoUrl == null
                        ? const Icon(
                            Icons.account_circle,
                            size: 20,
                            color: Colors.grey,
                          )
                        : null, // Sesuaikan dengan ukuran avatar yang diinginkan
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
    return Skeletonizer(
      enabled: _enabled,
      child: Scaffold(
        body: RefreshIndicator(
          color: Col.primaryColor,
          onRefresh: _refreshData,
          child: ScrollConfiguration(
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
                            const begin =
                                Offset(0.5, 0.0); // Mulai dari tengah layar
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
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      color: Col.greyColor,
                      iconSize: 24,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // TODO: implement notification icon
                        Navigator.pushNamed(context, '/comingsoon');
                      },
                      icon: const Icon(Icons.notifications_none_outlined),
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
                                buildMenuWidget(context),
                                const SizedBox(height: 20),
                                const RecentActivityWidget(),
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
          ),
        ),
      ),
    );
  }
}
