import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kajur_app/design/system.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;

  const SplashScreen({Key? key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Periksa apakah email sudah diverifikasi
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user != null && user.emailVerified) {
          // Email sudah diverifikasi, arahkan ke halaman beranda
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Email belum diverifikasi, arahkan ke halaman verifikasi email
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // User belum login, arahkan ke halaman login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/splash.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'Versi ${snapshot.data!.version}',
                  style: const TextStyle(
                    color: Col.blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
