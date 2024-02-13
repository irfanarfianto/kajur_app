import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/menu/menu_page.dart';
import 'package:kajur_app/screens/menu/web_view.dart';
import 'package:kajur_app/screens/products/list/list_products.dart';
import 'package:kajur_app/screens/products/tambah%20produk/add_products.dart';
import 'package:kajur_app/screens/widget/circular_button.dart';

Widget buildMenuWidget(BuildContext context, String userRole) {
  bool isStaffOrAdmin = (userRole == 'staf' || userRole == 'admin');

  return Column(
    children: [
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Col.secondaryColor,
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
                    true, // Display for all users
                  ),
                ),
                if (isStaffOrAdmin)
                  Expanded(
                    child: buildCircularButton(
                      context,
                      "Tambah",
                      Icons.add_shopping_cart_rounded,
                      const AddDataPage(),
                      true, // Display for all users
                    ),
                  ),
                Expanded(
                  child: buildCircularButton(
                    context,
                    "Siakad",
                    Icons.school,
                    const WebViewPage(
                      url:
                          'https://siakad.uhb.ac.id/a/www/auth?retselectedUrl=/',
                    ),
                    isStaffOrAdmin,
                  ),
                ),
                Expanded(
                  child: buildCircularButton(
                    context,
                    "Lainnya",
                    Icons.apps,
                    const MenuPage(), // You can replace this with the actual page
                    true, // Display for all users
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
