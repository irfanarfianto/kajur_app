import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:intl/intl.dart';

class AddProductDetailPage extends StatelessWidget {
  final String addedByName;
  final String productName;
  final int hargaJual;
  final int hargaPokok;
  final int jumlahIsi;
  final String kategori;
  final String imageUrl;
  final String deskripsi;
  final int stok;
  final int totalProfit;
  final int profitSatuan;
  final DateTime createdAt;

  const AddProductDetailPage({
    super.key,
    required this.addedByName,
    required this.productName,
    required this.hargaJual,
    required this.hargaPokok,
    required this.jumlahIsi,
    required this.kategori,
    required this.imageUrl,
    required this.deskripsi,
    required this.stok,
    required this.totalProfit,
    required this.profitSatuan,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Col.backgroundColor,
      appBar: AppBar(
        backgroundColor: Col.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                  color: Col.greyColor.withOpacity(.20), width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            color: Col.secondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/gif/success2.gif',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        productName,
                        style: Typo.headingTextStyle,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.coffee_outlined,
                          ),
                          const SizedBox(width: 5),
                          Text(kategori),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Berhasil Tersimpan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                   const Text(
                    'Rincian Produk',
                    style: Typo.emphasizedBodyTextStyle,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailItem('Ditambahkan Oleh', addedByName),
                  _buildDetailItem('Waktu', _formatDateTime(createdAt)),
                  const SizedBox(height: 10),
                  DottedDashedLine(
                    height: 0,
                    width: 100,
                    axis: Axis.horizontal,
                    dashColor: Col.greyColor.withOpacity(.20),
                  ),
                  const SizedBox(height: 10),
                   const Text('Deskripsi Produk',
                      style: Typo.emphasizedBodyTextStyle),
                  Text(
                    deskripsi,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  DottedDashedLine(
                    height: 0,
                    width: 100,
                    axis: Axis.horizontal,
                    dashColor: Col.greyColor.withOpacity(.20),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailItem(
                      'Harga Jual', '${currencyFormat.format(hargaJual)}/pcs'),
                  _buildDetailItem(
                      'Harga Pokok/Beli', currencyFormat.format(hargaPokok)),
                  _buildDetailItem('Jumlah Isi', '$jumlahIsi'),
                  Text(
                    '*bukan pack/dus',
                    style: TextStyle(
                      color: Col.greyColor.withOpacity(.50),
                      fontSize: 12,
                      fontWeight: Fw.regular,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DottedDashedLine(
                    height: 0,
                    width: 100,
                    axis: Axis.horizontal,
                    dashColor: Col.greyColor.withOpacity(.20),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailItem('Stok di Kantin', '$stok'),
                  const SizedBox(height: 10),
                  DottedDashedLine(
                    height: 0,
                    width: 100,
                    axis: Axis.horizontal,
                    dashColor: Col.greyColor.withOpacity(.20),
                  ),
                  const SizedBox(height: 10),
                   const Text('Perkiraan Profit',
                      style: Typo.emphasizedBodyTextStyle),
                  _buildDetailItem(
                      'Satuan /pcs', currencyFormat.format(profitSatuan),
                      isProfit: true),
                  _buildDetailItem(
                      'Total Profit', currencyFormat.format(totalProfit),
                      isProfit: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Col.blackColor,
                              backgroundColor: Col.secondaryColor,
                              surfaceTintColor: Col.secondaryColor,
                              elevation: 0,
                              side: BorderSide(
                                color: Col.greyColor.withOpacity(.20),
                              )),
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/add_produk');
                          },
                          child: const Text('Tambah Lagi'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/list_produk');
                          },
                          child: const Text('Selesai'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Metode untuk memformat DateTime menjadi string yang sesuai
  String _formatDateTime(DateTime dateTime) {
    // Sesuaikan format ini sesuai kebutuhan Anda
    return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id').format(dateTime);
  }

  Widget _buildDetailItem(String label, String value, {bool isProfit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:'),
        Row(
          children: [
            isProfit
                ? const Icon(
                    Icons.payments_outlined,
                    size: 12,
                    color: Col.greenAccent,
                  )
                : Container(),
            Text(
              value,
              style: isProfit
                  ? const TextStyle(
                      color: Col.greenAccent,
                      fontWeight: FontWeight.bold,
                    )
                  : Typo.emphasizedBodyTextStyle,
            ),
          ],
        ),
      ],
    );
  }
}
