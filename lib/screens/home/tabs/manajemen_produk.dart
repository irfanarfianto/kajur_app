import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/aktivitas/components/activity_widget.dart';
import 'package:kajur_app/screens/home/components/menu.dart';
import 'package:kajur_app/screens/home/components/total_produk_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManajemenProdukContent extends StatefulWidget {
  final String userRole; // Tambahkan parameter _userRole

  const ManajemenProdukContent(
      {super.key, required this.userRole}); // Ubah konstruktor

  @override
  State<ManajemenProdukContent> createState() => _ManajemenProdukContentState();
}

class _ManajemenProdukContentState extends State<ManajemenProdukContent> {
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _userRole = widget.userRole;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          buildTotalProductsWidget(context),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                buildMenuWidget(
                    context, _userRole), // Gunakan _userRole di sini
                const SizedBox(height: 20),
                buildRecentActivityWidget(context),
              ],
            ),
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
    );
  }
}
