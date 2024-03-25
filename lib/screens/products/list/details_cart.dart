import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'package:kajur_app/screens/products/list/cart_provider.dart';
import 'package:kajur_app/screens/products/list/update_cart.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/utils/global/common/toast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CartItemDetail extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartItemDetail({
    super.key,
    required this.cartItems,
  });

  @override
  _CartItemDetailState createState() => _CartItemDetailState();
}

class _CartItemDetailState extends State<CartItemDetail> {
  late Future<Map<String, String>> _userDataFuture;
  bool addTransportFee = false;
  double transportFee = 0;

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

  void _onShare(BuildContext context) async {
    Map<String, String> userData = await getUserData();

    String displayName = userData['displayName'] ?? 'Unknown User';

    String sharedText = 'Detail Becer\n';

    sharedText += 'Dibuat oleh: ${userData[displayName] ?? '-'}\n';
    sharedText += 'Nomor WhatsApp: ${userData['whatsapp'] ?? '-'}\n';

    // Tambahkan waktu saat ini
    sharedText +=
        'Waktu: ${DateFormat('dd MMMM yyyy HH:mm:ss', 'id').format(DateTime.now())}\n\n';
    sharedText += '------------------------------\n';

    for (var item in widget.cartItems) {
      sharedText +=
          '${item['data']['menu']} - ${hargaFormat.format(item['data']['hargaPokok'])} \n';
    }

    if (addTransportFee) {
      sharedText += 'Biaya Transportasi: ${hargaFormat.format(transportFee)}\n';
    }
    sharedText += '------------------------------\n';
    double subtotal = 0;
    for (var item in widget.cartItems) {
      subtotal += item['data']['hargaPokok'];
    }

    sharedText += 'Subtotal: ${hargaFormat.format(subtotal)}\n';
    sharedText += 'Jumlah produk: ${widget.cartItems.length}\n';
    sharedText += '==============================\n';

    sharedText +=
        'Total: ${hargaFormat.format(subtotal + (addTransportFee ? transportFee : 0))}\n\n';

    sharedText += '© ${DateTime.now().year} Kantin Kejujuran';

    try {
      await Share.share(sharedText, subject: 'Data Keranjang');
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  void _hapusProduk(String productId) {
    setState(() {
      widget.cartItems.removeWhere((item) => item['document'].id == productId);
    });
    showToast(message: 'Produk berhasil dihapus');
  }

  void _updateProduk(String productId, int newQuantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateCartItemQuantity(productId, newQuantity);
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

        double subtotal = 0;
        for (var item in widget.cartItems) {
          subtotal += item['jumlah'] * item['data']['hargaPokok'];
        }

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Nama Produk', style: Typo.titleTextStyle),
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
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        item['data']['menu'],
                                        style: Typo.titleTextStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController
                                                priceController =
                                                TextEditingController(
                                              text: item['data']['hargaPokok']
                                                  .toString(),
                                            );

                                            TextEditingController
                                                quantityController =
                                                TextEditingController(
                                              text: item['jumlah'].toString(),
                                            );

                                            return AlertDialog(
                                              title: const Text('Edit'),
                                              content: UpdateCart(
                                                productName: item['data']
                                                    ['menu'],
                                                priceController:
                                                    priceController,
                                                quantityController:
                                                    quantityController,
                                                onUpdate:
                                                    (newPrice, newQuantity) {
                                                  setState(() {
                                                    _updateProduk(
                                                        item['document'].id,
                                                        // double.parse(newPrice),
                                                        int.parse(newQuantity));
                                                  });
                                                },
                                                onDelete: () {
                                                  Navigator.pop(context);
                                                  _hapusProduk(
                                                      item['document'].id);
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Edit',
                                        style: Typo.emphasizedBodyTextStyle
                                            .copyWith(
                                          color: Col.primaryColor,
                                          fontWeight: Fw.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hargaFormat.format(item['jumlah'] *
                                          item['data']['hargaPokok']),
                                      style: Typo.bodyTextStyle,
                                    ),
                                    Text(
                                        '${item['jumlah']}x ${hargaFormat.format(item['data']['hargaPokok'])}',
                                        style: Typo.emphasizedBodyTextStyle
                                            .copyWith(
                                          color: Col.greyColor,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ],
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
                          hargaFormat.format(
                              subtotal + (addTransportFee ? transportFee : 0)),
                          style: Typo.emphasizedBodyTextStyle,
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
                  onPressed: () {
                    _onShare(context);
                  },
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
