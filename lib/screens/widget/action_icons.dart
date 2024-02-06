import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class ActivityIcon extends StatelessWidget {
  final String? action;

  const ActivityIcon({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (action) {
      case 'Tambah Produk':
        iconData = Icons.add_business;
        iconColor = Col.greenAccent;
        backgroundColor = Col.greenAccent.withOpacity(0.1);
        break;
      case 'Edit Produk':
        iconData = Icons.edit_note;
        iconColor = Col.orangeAccent;
        backgroundColor = Col.orangeAccent.withOpacity(0.1);
        break;
      case 'Update Stok':
        iconData = Icons.inventory;
        iconColor = Col.primaryColor;
        backgroundColor = Col.primaryColor.withOpacity(0.1);
        break;
      case 'Hapus Produk':
        iconData = Icons.delete_sharp;
        iconColor = Col.redAccent;
        backgroundColor = Col.redAccent.withOpacity(0.1);
        break;
      default:
        iconData = Icons.campaign;
        iconColor = Col.greyColor;
        backgroundColor = Col.greyColor.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
}
