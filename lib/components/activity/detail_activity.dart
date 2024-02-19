import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:kajur_app/components/produk/edit_produk.dart';
import 'package:kajur_app/components/produk/hapus_produk.dart';
import 'package:kajur_app/components/produk/tambah_produk.dart';
import 'package:kajur_app/components/keuangan/transaksi_keluar.dart';
import 'package:kajur_app/components/keuangan/transaksi_masuk.dart';
import 'package:kajur_app/components/produk/udpate_stok.dart';
import 'package:kajur_app/components/menu%20button/menu.dart';
import 'package:kajur_app/screens/widget/action_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityDetailPage extends StatefulWidget {
  final Map<String, dynamic> activityData;

  const ActivityDetailPage({super.key, required this.activityData});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  void openWhatsApp(BuildContext context) async {
    String whatsappNumber = "+6282322546452";
    String messageText = "Hello min";

    String whatsappURL = "https://wa.me/$whatsappNumber?text=$messageText";

    if (await canLaunchUrl(
      Uri.parse(whatsappURL),
    )) {
      await launchUrl(
        Uri.parse(whatsappURL),
      );
    } else {
      showToast(message: "WhatsApp is not installed");
    }
  }

  @override
  Widget build(BuildContext context) {
    String action = widget.activityData['action'] ?? '';
    String activityId = widget.activityData['id'] ?? '';
    String userRole = '';

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: true),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Col.backgroundColor,
          ),
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Col.secondaryColor,
                    border:
                        Border.all(color: const Color(0x309E9E9E), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Col.greyColor.withOpacity(.10),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ActivityIcon(action: action),
                      const SizedBox(height: 8),
                      Text(action, style: Typo.titleTextStyle),
                      const SizedBox(height: 5),
                      Text(
                          'Oleh ${widget.activityData['userName'] ?? 'Unknown'}',
                          style: Typo.emphasizedBodyTextStyle),
                      Text(
                        'ID Aktivitas $activityId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Col.greyColor,
                        ),
                      ),
                      Text(
                        (widget.activityData['timestamp'] != null
                            ? DateFormat('dd MMMM y - HH:mm ', 'id').format(
                                (widget.activityData['timestamp'] as Timestamp)
                                    .toDate())
                            : 'Timestamp tidak tersedia'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Col.greyColor,
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (action == 'Tambah Produk')
                        buildTambahProdukWidget(context, widget.activityData),
                      if (action == 'Update Stok')
                        buildUpdateStokWidget(context, widget.activityData),
                      if (action == 'Edit Produk')
                        buildEditProdukWidget(context, widget.activityData),
                      if (action == 'Hapus Produk')
                        buildHapusProdukWidget(context, widget.activityData),
                      if (action == 'Pemasukan')
                        buildTransaksiMasukWidget(context, widget.activityData),
                      if (action == 'Pengeluaran')
                        buildTransaksiKeluarWidget(
                            context, widget.activityData),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                if (action == 'Tambah Produk')
                  buildMenuWidget(context, userRole),
                if (action == 'Update Stok') buildMenuWidget(context, userRole),
                if (action == 'Edit Produk') buildMenuWidget(context, userRole),
                const SizedBox(height: 25),
                const Text(
                  'Butuh bantuan?',
                ),
                InkWell(
                  onTap: () {
                    openWhatsApp(context);
                  },
                  child: const Text('Hubungi Pengurus Kajur',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Col.primaryColor,
                      )),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
