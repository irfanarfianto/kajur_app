import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/utils/global/common/toast.dart';

class CartItemDetail extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  // Added documentId property

  const CartItemDetail({
    Key? key,
    required this.cartItems,
    // Required documentId
  }) : super(key: key);

  @override
  _CartItemDetailState createState() => _CartItemDetailState();
}

class _CartItemDetailState extends State<CartItemDetail> {
  late Future<Map<String, String>> _userDataFuture;
  bool addTransportFee = false;
  double transportFee = 0;
  final TextEditingController _hargaPokokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userDataFuture = getUserData();
  }

  final hargaFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<Map<String, String>> getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .get();

    String whatsapp = userSnapshot.data()?['whatsapp'] ?? '';
    String displayName = userSnapshot.data()?['displayName'] ?? '';
    String username = userSnapshot.data()?['username'] ?? '';

    if (displayName.isEmpty) {
      displayName = username;
    }

    return {'whatsapp': whatsapp, 'displayName': displayName};
  }

  Future<void> _updateHargaPokok(String productId) async {
    try {
      if (_hargaPokokController.text.isEmpty) {
        AnimatedSnackBar.material(
          'Harga pokok tidak boleh kosong',
          type: AnimatedSnackBarType.info,
        ).show(context);
        return;
      }

      String hargaPokokText = _hargaPokokController.text;
      int newHargaPokok =
          int.tryParse(hargaPokokText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      // Validasi input
      if (newHargaPokok >= 0) {
        User? user = FirebaseAuth.instance.currentUser;
        String? userId = user?.uid;
        String? userName = user?.displayName ?? 'Unknown User';

        // Mendapatkan detail produk sebelum diperbarui
        DocumentSnapshot oldProductSnapshot = await FirebaseFirestore.instance
            .collection('kantin')
            .doc(productId) // Use productId
            .get();
        Map<String, dynamic> oldProductData =
            oldProductSnapshot.data() as Map<String, dynamic>;

        // Setelah semua validasi, tentukan waktu pembaruan
        DateTime updatedAt = DateTime.now();

        // Hitung ulang profit setiap satuan berdasarkan harga pokok yang baru
        num newProfitSatuan = (oldProductData['hargaJual'] - newHargaPokok) /
            oldProductData['jumlahIsi'];
        num newTotalProfit = newProfitSatuan * oldProductData['jumlahIsi'];

        // Update harga pokok di produk
        await FirebaseFirestore.instance
            .collection('kantin')
            .doc(productId) // Use productId
            .update({
          'hargaPokok': newHargaPokok,
          'totalProfit': newTotalProfit,
          'profitSatuan': newProfitSatuan,
          'updatedAt': updatedAt, // Tetapkan waktu pembaruan di sini juga
          'lastEditedBy': userId,
          'lastEditedByName': userName,
        });

        showToast(message: 'Harga pokok berhasil diperbarui');

        Navigator.pop(context);
      } else {
        showToast(message: 'Mohon isi harga pokok dengan angka positif');
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        String whatsapp = snapshot.data?['whatsapp'] ?? '';
        String displayName = snapshot.data?['displayName'] ?? '';

        double totalHarga = 0;

        for (var item in widget.cartItems) {
          totalHarga += item['data']['hargaPokok'];
        }

        if (addTransportFee) {
          totalHarga += transportFee;
        }

        double subtotal = totalHarga - transportFee;

        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Col.backgroundColor,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'Keranjang Becer',
                  style: Typo.titleTextStyle,
                ),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      DateFormat('dd MMMM yyyy HH:mm:ss', 'id')
                          .format(DateTime.now()),
                      style: Typo.bodyTextStyle.copyWith(
                        color: Col.greyColor,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Dibuat oleh: $displayName',
                      style: Typo.emphasizedBodyTextStyle,
                    ),
                    if (whatsapp.isNotEmpty)
                      Text(
                        'Whatsapp: $whatsapp',
                        style: Typo.emphasizedBodyTextStyle,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Nama Produk', style: Typo.titleTextStyle),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text('Tambah Produk',
                                  style: Typo.emphasizedBodyTextStyle.copyWith(
                                    color: Col.primaryColor,
                                    fontWeight: Fw.bold,
                                  )),
                            ),
                            Text('Harga Pokok',
                                style: Typo.emphasizedBodyTextStyle.copyWith(
                                  color: Col.greyColor,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              DottedDashedLine(
                height: 2,
                strokeWidth: 1,
                width: double.infinity,
                axis: Axis.horizontal,
                dashColor: Col.greyColor.withOpacity(0.50),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = widget.cartItems[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['data']['menu'],
                                  style: Typo.titleTextStyle,
                                ),
                                InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          TextEditingController controller =
                                              TextEditingController(
                                            text: item['data']['hargaPokok']
                                                .toString(),
                                          );

                                          return AlertDialog(
                                            title: const Text(
                                                'Update Harga Pokok'),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // _updateHargaPokok(
                                                  //     item['documentId']
                                                  //         .toString());
                                                },
                                                child: const Text('Simpan'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text('Edit',
                                        style: Typo.emphasizedBodyTextStyle
                                            .copyWith(
                                                color: Col.primaryColor,
                                                fontWeight: Fw.bold,
                                                fontSize: 12))),
                              ],
                            ),
                            trailing: Text(
                              hargaFormat.format(item['data']['hargaPokok']),
                              style: Typo.bodyTextStyle,
                            ),
                          ),
                          DottedDashedLine(
                            height: 2,
                            strokeWidth: 1,
                            width: double.infinity,
                            axis: Axis.horizontal,
                            dashColor: Col.greyColor.withOpacity(0.1),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      decoration: BoxDecoration(
                        color: Col.greyColor.withOpacity(0.1),
                      ),
                      child: Row(children: [
                        const Icon(
                          Icons.info,
                          color: Col.greyColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Pastikan produk sudah benar sebelum dicatat',
                          style: Typo.subtitleTextStyle.copyWith(
                            color: Col.greyColor,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: Typo.bodyTextStyle),
                          Text(
                            hargaFormat.format(subtotal),
                            style: Typo.emphasizedBodyTextStyle,
                          ),
                        ],
                      ),
                    ),
                    if (transportFee > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Biaya Transportasi',
                                style: Typo.bodyTextStyle),
                            Text(
                              hargaFormat.format(transportFee),
                              style: Typo.emphasizedBodyTextStyle,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('Tambah uang transport',
                                  style: Typo.bodyTextStyle
                                      .copyWith(fontWeight: Fw.bold)),
                              Text(
                                'Biaya transport Rp 10.000',
                                style: Typo.subtitleTextStyle.copyWith(
                                    color: Col.greyColor, fontSize: 12),
                              ),
                            ],
                          ),
                          FlutterSwitch(
                              activeColor: Col.primaryColor,
                              inactiveColor: Col.greyColor,
                              height: 25,
                              width: 50,
                              padding: 2,
                              value: addTransportFee,
                              onToggle: (value) {
                                setState(() {
                                  addTransportFee = value;
                                  if (value) {
                                    transportFee = 10000;
                                  } else {
                                    transportFee = 0;
                                  }
                                });
                              })
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DottedDashedLine(
                      height: 2,
                      strokeWidth: 1,
                      width: double.infinity,
                      axis: Axis.horizontal,
                      dashColor: Col.greyColor.withOpacity(0.50),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 1,
            shadowColor: Col.greyColor,
            color: Col.backgroundColor,
            height: 106,
            shape: const CircularNotchedRectangle(),
            padding: const EdgeInsetsDirectional.only(
                bottom: 4, start: 20, end: 20, top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pengeluaran',
                          style: Typo.titleTextStyle,
                        ),
                        Text(
                          'Pengeluaran ini akan dicatat',
                          style: Typo.subtitleTextStyle
                              .copyWith(color: Col.greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          hargaFormat.format(totalHarga),
                          style: Typo.titleTextStyle,
                        ),
                        Text(
                          'Total produk ${widget.cartItems.length}',
                          style: Typo.subtitleTextStyle
                              .copyWith(color: Col.greyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Catat dan Kirim'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
