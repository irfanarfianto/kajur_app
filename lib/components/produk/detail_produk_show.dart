// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:kajur_app/design/system.dart';
// import 'package:kajur_app/screens/products/details_products.dart';

// void showDetailOverlay(BuildContext context, Map<String, dynamic> data) {
//   showModalBottomSheet(
//     enableDrag: true,
//     isScrollControlled: true,
//     constraints: BoxConstraints(
//       maxHeight: MediaQuery.of(context).size.height * 0.3,
//     ),
//     context: context,
//     builder: (BuildContext context) {
//       return Column(
//         children: [
//           const SizedBox(height: 16),
//           Container(
//             height: 5,
//             width: 40,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(100),
//               color: Col.greyColor.withOpacity(.50),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Wrap(
//               children: [
//                 Card(
//                   elevation: 0,
//                   color: Col.secondaryColor,
//                   shadowColor: Col.greyColor.withOpacity(0.10),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Hero(
//                           tag: 'product_image_${data['id']}',
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: CachedNetworkImage(
//                               imageUrl: data['image'],
//                               fit: BoxFit.cover,
//                               errorWidget: (context, url, error) => Container(
//                                 color: Col.greyColor.withOpacity(0.10),
//                                 child: Icon(Icons.hide_image_rounded,
//                                     color: Col.greyColor.withOpacity(0.50)),
//                               ),
//                               placeholder: (context, url) => Container(
//                                 color: Col.greyColor.withOpacity(0.10),
//                                 child: Icon(Icons.image,
//                                     color: Col.greyColor.withOpacity(0.50)),
//                               ),
//                               width: 80,
//                               height: 80,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 data['menu'],
//                                 style: Typo.emphasizedBodyTextStyle,
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 1,
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 '*Diperbarui ${DateFormat('dd MMM y HH:mm', 'id_ID').format(data['updatedAt']?.toDate() ?? DateTime.now())}',
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Col.greyColor,
//                                   fontStyle: FontStyle.italic,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DetailProdukPage(
//                           documentId: data['id'],
//                         ),
//                       ),
//                     );
//                   },
//                   child: const Text('Lihat Detail'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
