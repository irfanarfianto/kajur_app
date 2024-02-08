import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/component/circularButton.dart';
import 'package:kajur_app/screens/home/menu_page.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildMenuWidget(BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Terjadi kesalahan: ${snapshot.error}'),
        );
      }

      // Jika data belum dimuat
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Tampilkan widget kosong
        return const SizedBox.shrink();
      }

      // Jika data sudah dimuat
      if (snapshot.hasData) {
        // Setelah mendapatkan data user, cek peran user
        Map<String, dynamic>? userData =
            snapshot.data!.data() as Map<String, dynamic>?;
        if (userData != null) {
          String userRole = userData['role'];
          bool isStaffOrAdmin = (userRole == 'staf' || userRole == 'admin');

          return Column(
            children: [
              Center(
                child: Skeleton.keep(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Col.secondaryColor,
                      border: Border.all(color: Col.greyColor.withOpacity(.10)),
                      boxShadow: [
                        BoxShadow(
                          color: Col.greyColor.withOpacity(.10),
                          offset: const Offset(0, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: buildCircularButton(
                              context,
                              "List Produk",
                              Icons.ballot,
                              const ListProdukPage(),
                              isStaffOrAdmin,
                            ),
                          ),
                          Expanded(
                            child: buildCircularButton(
                              context,
                              "Tambah",
                              Icons.add_shopping_cart_rounded,
                              const AddDataPage(),
                              isStaffOrAdmin,
                            ),
                          ),
                          Expanded(
                            child: buildCircularButton(
                              context,
                              "Keuangan",
                              Icons.account_balance_wallet,
                              const ComingSoonPage(),
                              isStaffOrAdmin,
                            ),
                          ),
                          Expanded(
                            child: buildCircularButton(
                              context,
                              "Lainnya",
                              Icons.apps,
                              const MenuPage(),
                              isStaffOrAdmin,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      }

      // Jika tidak ada data, Anda dapat menampilkan widget kosong atau pesan lain
      return const SizedBox.shrink(); // Misalnya, widget kosong
    },
  );
}
