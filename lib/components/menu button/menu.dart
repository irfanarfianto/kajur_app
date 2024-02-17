import 'package:flutter/material.dart';
import 'package:kajur_app/components/produk/kirim_data_produk.dart';
import 'package:kajur_app/screens/menu/menu_page.dart';
import 'package:kajur_app/screens/webviews/web_view_page.dart';
import 'package:kajur_app/screens/products/list/list_products_page.dart';
import 'package:kajur_app/screens/products/tambah%20produk/add_products_page.dart';
import 'package:kajur_app/screens/widget/circular_button.dart';

Widget buildMenuWidget(BuildContext context, String userRole) {
  bool isStaffOrAdmin = (userRole == 'staf' || userRole == 'admin');

  return GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    children: [
      buildCircularButton(
        context,
        "List Produk",
        Icons.ballot,
        const ListProdukPage(),
        true, // Display for all users
      ),
      // if (isStaffOrAdmin)
      buildCircularButton(
        context,
        "Tambah",
        Icons.add_shopping_cart_rounded,
        const AddDataPage(),
        true, // Display for all users
      ),
      buildCircularButton(
        context,
        "Grafik",
        Icons.school,
        const WebViewPage(
          url: 'https://siakad.uhb.ac.id/a/www/auth?retselectedUrl=/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Scalsa",
        Icons.school,
        const WebViewPage(
          url: 'https://fst.scalsa.uhb.ac.id/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Chat GPT",
        Icons.chat_bubble_outline_outlined,
        const WebViewPage(
          url: 'https://chat.openai.com/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Kirim Data",
        Icons.share,
        const ShareProduk(),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Google",
        Icons.public,
        const WebViewPage(
          url: 'https://www.google.com/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Lainnya",
        Icons.apps,
        const MenuPage(), // You can replace this with the actual page
        true, // Display for all users
      ),
    ],
  );
}
