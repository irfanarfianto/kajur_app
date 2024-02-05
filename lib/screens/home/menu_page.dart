import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/component/circularButton.dart';
import 'package:kajur_app/screens/home/web_view.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late User? user;
  bool isStaffOrAdmin = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _checkUserRole();
  }

  // Method to check user role and update isStaffOrAdmin accordingly
  void _checkUserRole() {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((DocumentSnapshot document) {
        if (document.exists) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          String userRole = userData['role'];

          // Check if user is staff or admin
          if (userRole == 'staf' || userRole == 'admin') {
            setState(() {
              isStaffOrAdmin = true;
            });
          }
        }
      }).catchError((error) {
        print("Error getting user role: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildProductManagement(context),
            const SizedBox(height: 16),
            _buildFinance(context),
            const SizedBox(height: 16),
            _buildShortcuts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductManagement(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Manajemen Produk', style: Typo.titleTextStyle),
        ),
        const SizedBox(height: 10),
        Container(
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
          child: Row(
            children: [
              buildCircularButton(
                context,
                "List Produk",
                Icons.ballot,
                const ListProdukPage(),
                isStaffOrAdmin,
              ),
              const SizedBox(width: 16),
              buildCircularButton(
                context,
                "Tambah",
                Icons.add_shopping_cart_rounded,
                const AddDataPage(),
                isStaffOrAdmin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Keuangan', style: Typo.titleTextStyle),
        ),
        const SizedBox(height: 10),
        Container(
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
          child: Row(
            children: [
              buildCircularButton(
                context,
                "Keuangan",
                Icons.account_balance_wallet,
                const ComingSoonPage(),
                isStaffOrAdmin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Jalan Pintas', style: Typo.titleTextStyle),
        ),
        const SizedBox(height: 10),
        Container(
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
          child: Row(
            children: [
              buildCircularButton(
                context,
                "Scalsa",
                Icons.school,
                const WebViewPage(
                  url: 'https://fst.scalsa.uhb.ac.id/',
                ),
                isStaffOrAdmin,
              ),
              const SizedBox(width: 16),
              buildCircularButton(
                context,
                "Siakad",
                Icons.school,
                const WebViewPage(
                  url: 'https://siakad.uhb.ac.id/a/www/auth?retselectedUrl=/',
                ),
                isStaffOrAdmin,
              ),
              const SizedBox(width: 16),
              buildCircularButton(
                context,
                "Google",
                Icons.public,
                const WebViewPage(
                  url: 'https://www.google.com/',
                ),
                isStaffOrAdmin,
              ),
            ],
          ),
        ),
      ],
    );
  }
}