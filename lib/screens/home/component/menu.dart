import 'package:flutter/material.dart';
import 'package:kajur_app/comingsoon/comingsoon.dart';
import 'package:kajur_app/design/system.dart';
import 'package:kajur_app/screens/home/component/circularButton.dart';
import 'package:kajur_app/screens/products/add_products.dart';
import 'package:kajur_app/screens/products/list_products.dart';
import 'package:kajur_app/screens/products/stok/stok_produk.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget buildMenuWidget(BuildContext context) {
  return Column(
    children: [
      Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: DesignSystem.secondaryColor,
            border: Border.all(color: DesignSystem.greyColor.withOpacity(.10)),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.greyColor.withOpacity(.10),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.keep(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu',
                      style: DesignSystem.titleTextStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
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
                      child: buildCircularButton(context, "Pengeluaran",
                          Icons.money_off, const ComingSoonPage()),
                    ),
                    Expanded(
                      child: buildCircularButton(context, "Pemasukan",
                          Icons.account_balance_wallet, const ComingSoonPage()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
