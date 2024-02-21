import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildUserWidget(BuildContext context, User? currentUser) {
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
                  backgroundColor: Col.whiteColor,
                  backgroundImage: photoUrl != null
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  radius: 20,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.account_circle,
                          size: 45,
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
