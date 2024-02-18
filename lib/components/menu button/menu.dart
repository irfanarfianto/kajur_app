import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        "Produk",
        FontAwesomeIcons.burger,
        const ListProdukPage(),
        true, // Display for all users
      ),
      // if (isStaffOrAdmin)
      buildCircularButton(
        context,
        "Tambah",
        FontAwesomeIcons.cartArrowDown,
        const AddDataPage(),
        true, // Display for all users
      ),
      buildCircularButton(
        context,
        "Siakad",
        FontAwesomeIcons.graduationCap,
        const WebViewPage(
          url: 'https://siakad.uhb.ac.id/a/www/auth?retselectedUrl=/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Scalsa",
        FontAwesomeIcons.chalkboardUser,
        const WebViewPage(
          url: 'https://fst.scalsa.uhb.ac.id/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Chat GPT",
        FontAwesomeIcons.message,
        const WebViewPage(
          url: 'https://chat.openai.com/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Kirim Data",
        FontAwesomeIcons.shareNodes,
        const ShareProduk(),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Google",
        FontAwesomeIcons.google,
        const WebViewPage(
          url: 'https://www.google.com/',
        ),
        isStaffOrAdmin,
      ),
      buildCircularButton(
        context,
        "Lainnya",
        FontAwesomeIcons.rectangleList,
        const MenuPage(), // You can replace this with the actual page
        true, // Display for all users
      ),
    ],
  );
}
