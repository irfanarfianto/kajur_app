import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kajur_app/global/common/toast.dart';
import 'package:kajur_app/screens/widget/catergory_icon.dart';
import 'package:kajur_app/screens/widget/transaksi_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design/system.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const TransactionDetailScreen({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
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
                  border: Border.all(color: const Color(0x309E9E9E), width: 1),
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
                    TransaksiIcon(
                      transactionType: transactionData['transactionType'],
                    ),
                    const SizedBox(height: 8),
                    Text(transactionData['transactionType'],
                        style: Typo.titleTextStyle),
                    const SizedBox(height: 5),
                    Text('Oleh ${transactionData['recordedBy'] ?? 'Unknown'}',
                        style: Typo.emphasizedBodyTextStyle),
                    Text(
                      'ID Transaksi ${transactionData['transactionId']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Col.greyColor,
                      ),
                    ),
                    Text(
                      (transactionData['timestamp'] != null
                          ? DateFormat('dd MMMM y - HH:mm WIB', 'id').format(
                              (transactionData['timestamp'] as Timestamp)
                                  .toDate())
                          : 'Timestamp tidak tersedia'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Col.greyColor,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Transaksi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Col.greyColor,
                          ),
                        ),
                        DottedDashedLine(
                          height: 2,
                          strokeWidth: 1,
                          width: 200,
                          axis: Axis.horizontal,
                          dashColor: Col.greyColor.withOpacity(0.50),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status:',
                            style: Typo.emphasizedBodyTextStyle),
                        Row(
                          children: [
                            const Text(
                              'Selesai',
                              style:
                                  TextStyle(fontSize: 14, fontWeight: Fw.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  //
                                  borderRadius: BorderRadius.circular(50),
                                  color: Col.greenAccent),
                              child: const Icon(
                                Icons.check,
                                color: Col.whiteColor,
                                size: 12,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sumber:',
                            style: Typo.emphasizedBodyTextStyle),
                        Row(
                          children: [
                            Text(
                              '${transactionData['category'] ?? 'Uncategorized'}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: Fw.bold),
                            ),
                            CategoryIcon(
                              category: transactionData['category'],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah:',
                            style: Typo.emphasizedBodyTextStyle),
                        Row(
                          children: [
                            Text(
                              currencyFormat.format(transactionData['amount']),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: Fw.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // buatkan text link

              InkWell(
                  onTap: () {
                    openWhatsApp(context);
                  },
                  child: const Text('Butuh bantuan?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Col.primaryColor,
                      ))),
            ],
          ),
        ),
      ),
    );
  }

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
}
