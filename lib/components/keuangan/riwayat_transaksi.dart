import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kajur_app/data/riwayat%20transaksi/transaksi_services.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/components/keuangan/detail_transaksi.dart';
import 'package:kajur_app/screens/widget/catergory_icon.dart';
import 'package:kajur_app/screens/widget/transaksi_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionHistory extends StatelessWidget {
  final TransactionService transactionService = TransactionService();
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  TransactionHistory({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: transactionService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: List.generate(
              4,
              (index) => Skeletonizer(
                enabled: true,
                child: Column(
                  children: [
                    ListTile(
                      leading: Skeleton.leaf(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      title: Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey[300],
                      ),
                      subtitle: Container(
                        width: 100,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.grey[300],
                            size: 15,
                          ),
                          Container(
                            width: 60,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    if (index < 2) // Don't add Divider after the last item
                      Divider(
                        thickness: 1,
                        color: Colors.grey[300],
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        // Data sudah tersedia
        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return SingleChildScrollView(
          child: Column(
            children: documents.asMap().entries.map((entry) {
              final index = entry.key;
              final document = entry.value;
              final transaction = document.data() as Map<String, dynamic>;
              final amount = transaction['amount'];

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transactionData: transaction,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Skeleton.leaf(
                        child: TransaksiIcon(
                          transactionType: transaction['transactionType'],
                        ),
                      ),
                      title: Text(
                        transaction['transactionType'],
                        style: Typo.emphasizedBodyTextStyle,
                      ),
                      subtitle: CarouselSlider(
                        disableGesture: true,
                        items: [
                          SizedBox(
                            width: 5,
                            child: Text(
                              transaction['recordedBy'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                transaction['category'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: Fw.bold,
                                ),
                              ),
                              CategoryIcon(
                                category: transaction['category'],
                              ),
                            ],
                          ),
                        ],
                        options: CarouselOptions(
                          viewportFraction: 1,
                          aspectRatio: 2 / 1.5,
                          height: 20,
                          autoPlayInterval: const Duration(seconds: 8),
                          autoPlay: true,
                          scrollDirection: Axis.vertical,
                        ),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            transaction['transactionType'] == 'Pengeluaran'
                                ? '-${currencyFormat.format(amount)}'
                                : currencyFormat.format(amount),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: Fw.bold,
                              color: transaction['transactionType'] ==
                                      'Pengeluaran'
                                  ? null
                                  : Col.greenAccent,
                            ),
                          ),
                          Text(
                            (transaction['timestamp'] != null
                                ? DateFormat('dd MMM HH:mm WIB', 'id').format(
                                    (transaction['timestamp'] as Timestamp)
                                        .toDate())
                                : 'Timestamp tidak tersedia'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < documents.length - 1)
                    Divider(
                      thickness: 1,
                      color: Col.greyColor.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
