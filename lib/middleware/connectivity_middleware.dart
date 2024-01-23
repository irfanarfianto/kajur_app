import 'package:flutter/material.dart';
import 'package:kajur_app/utils/internet_utils.dart';

class ConnectivityMiddleware extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkInternetConnectionAndNavigate(route);
  }

  void _checkInternetConnectionAndNavigate(Route<dynamic> route) async {
    if (route is PageRoute && await checkInternetConnection()) {
      // Koneksi internet tersedia, lanjutkan navigasi
      Navigator.of(route.navigator!.context).push(route);

    } else {
      // Tampilkan CircularProgressIndicator dalam overlay
      final overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      );

      // Tambahkan overlayEntry ke overlay
      Overlay.of(route.navigator!.context).insert(overlayEntry);

      // Setelah menunggu, cek koneksi internet lagi
      while (await checkInternetConnection() == false) {
        await Future.delayed(const Duration(seconds: 2));
      }

      // Tutup overlay
      overlayEntry.remove();

      // Lanjutkan navigasi jika koneksi internet tersedia
      route.navigator!.push(route);
    }
  }
}
