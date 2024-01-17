import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:kajur_app/screens/products/stok/stok_produk.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: DesignSystem.backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: DesignSystem.greyColor.withOpacity(.50),
            ),
          ),
          const SizedBox(height: 16),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: DesignSystem.greyColor.withOpacity(.10),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: buildCircularButton(
                    context, "List Produk", Icons.list, const ListProdukPage()),
              ),
              Expanded(
                child: buildCircularButton(
                    context, "Tambah", Icons.add, const AddDataPage()),
              ),
              Expanded(
                child: buildCircularButton(
                    context, "Edit", Icons.edit, const ListProdukPage()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: buildCircularButton(
                    context, "Stok", Icons.inventory, const StockPage()),
              ),
              Expanded(
                child: buildCircularButton(
                    context, "Pengeluaran", Icons.money_off, const ComingSoonPage()),
              ),
              Expanded(
                child: buildCircularButton(
                    context, "Pemasukan", Icons.attach_money, const ComingSoonPage()),
              ),
            ],
          ),

          const Spacer(), // Spacer to push the close button to the bottom
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: DesignSystem.greyColor.withOpacity(.15),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
              },
              icon: const Icon(Icons.close),
              iconSize: 25,
              color: DesignSystem.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCircularButton(
      BuildContext context, String label, IconData icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: DesignSystem.primaryColor,
            ),
            child: IconButton(
              onPressed: () {
                // Handle button tap
                print("$label pressed");
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => screen));
              },
              icon: Icon(icon),
              iconSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
