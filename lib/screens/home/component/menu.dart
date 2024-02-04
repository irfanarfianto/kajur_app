import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/component/circularButton.dart';
import 'package:kajur_app/screens/home/menu_page.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildMenuWidget(BuildContext context) {
  return Column(
    children: [
      Center(
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: buildCircularButton(context, "List Produk",
                      Icons.ballot, const ListProdukPage()),
                ),
                Expanded(
                  child: buildCircularButton(context, "Tambah",
                      Icons.add_shopping_cart_rounded, const AddDataPage()),
                ),
                Expanded(
                  child: buildCircularButton(context, "Keuangan",
                      Icons.account_balance_wallet, const ComingSoonPage()),
                ),
                Expanded(
                  child: buildCircularButton(
                      context, "Lainnya", Icons.apps, const MenuPage()),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
