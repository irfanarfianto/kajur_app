// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:kajur_app/design/system.dart';
// import 'package:share_plus/share_plus.dart';

// String text = '';
// String subject = '';
// String userId = FirebaseAuth.instance.currentUser!.uid;
// double _sliderValue = 5; // Nilai default slider

// Future<void> _getDataFromFirestore() async {
//   try {
//     CollectionReference produkCollection =
//         FirebaseFirestore.instance.collection('kantin');
//     // Mengambil data produk dengan stok di bawah nilai slider
//     QuerySnapshot querySnapshot =
//         await produkCollection.where('stok', isLessThan: _sliderValue).get();

//     // Mengecek apakah ada produk dengan stok di bawah nilai slider
//     if (querySnapshot.docs.isNotEmpty) {
//       int totalHargaPokok = 0; // Inisialisasi total harga pokok

//       String textData = '';

//       // Mendapatkan informasi pengguna yang sedang login sekali
//       User? user = FirebaseAuth.instance.currentUser;
//       String senderName = user != null
//           ? user.displayName ?? user.email ?? 'Unknown User'
//           : 'Unknown User';

//       // Format waktu saat ini sekali
//       String formattedDate =
//           DateFormat('EEEE, dd MMMM y - HH:mm:ss', 'id').format(DateTime.now());

//       // Menambahkan informasi pengguna dan waktu sekali
//       textData += 'Pengirim: $senderName\n'
//           '$formattedDate\n\n';

//       for (var document in querySnapshot.docs) {
//         String menu = document['menu'];
//         int hargaPokok = document['hargaPokok'] ?? 0;
//         int qty = document['stok'] ?? 0;

//         // Menambahkan garis pembatas setelah setiap produk
//         textData += '---------------------------\n'
//             'Nama produk: $menu\n'
//             'Harga pokok: ${_formatCurrency(hargaPokok)}\n' // Format uang ke Rupiah
//             'Sisa stok: ${qty > 0 ? qty : "Stok Habis"}\n';

//         // Menambahkan harga pokok ke total
//         totalHargaPokok += hargaPokok;
//       }

//       // Menambahkan keterangan total harga pokok
//       textData +=
//           '---------------------------\nPerkiraan uang yang harus\ndibayar: ${_formatCurrency(totalHargaPokok)}\n\n\n'
//           'Pengurus Kantin Kejujuran 2024 🙌';

//       setState(() {
//         text = textData;
//       });
//     } else {
//       setState(() {
//         text = 'Tidak ada produk dengan stok di bawah $_sliderValue';
//       });
//     }
//   } catch (e) {
//     print("Error: $e");
//     // Handle error jika diperlukan
//   }
// }

// void showShareOverlay(BuildContext context, Function(String)) {
//   showModalBottomSheet(
//     enableDrag: true,
//     isScrollControlled: true,
//     constraints: BoxConstraints(
//       maxHeight: MediaQuery.of(context).size.height * 0.6,
//     ),
//     context: context,
//     builder: (BuildContext context) {
//       return Stack(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Col.secondaryColor,
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: Col.greyColor.withOpacity(.50)),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Batasi stok < ${_sliderValue.toInt()}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Slider(
//                         activeColor: Col.primaryColor,
//                         inactiveColor: Col.primaryColor.withOpacity(0.1),
//                         value: _sliderValue.toDouble(),
//                         min: 0,
//                         max: 15,
//                         divisions: 15,
//                         label: _sliderValue.toInt().toString(),
//                         onChanged: (newValue) {
//                           setState(() {
//                             _sliderValue = newValue;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Col.secondaryColor,
//                   ),
//                   child: ScrollConfiguration(
//                     behavior: const ScrollBehavior().copyWith(overscroll: true),
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: FutureBuilder(
//                         future: _getDataFromFirestore(),
//                         builder: (context, snapshot) {
//                           return Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   text,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                                 // Other widgets from FutureBuilder if any...
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               // gradien
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       stops: const [
//                     0.0,
//                     1.0
//                   ],
//                       colors: [
//                     Col.secondaryColor.withOpacity(0.1),
//                     Col.secondaryColor,
//                   ])),
//               height: 50,
//             ),
//           ),
//         ],
//       );
//     },
//   );

//   String _formatCurrency(int amount) {
//     NumberFormat currencyFormat = NumberFormat.currency(
//       locale: 'id',
//       symbol: 'Rp ',
//       decimalDigits: 0,
//     );
//     return currencyFormat.format(amount);
//   }

//   void _onShare(BuildContext context) async {
//     final box = context.findRenderObject() as RenderBox?;
//     await Share.share(text,
//         subject: subject,
//         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
//   }
// }
