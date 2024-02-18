import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        iconData = FontAwesomeIcons.cartArrowDown;
        iconColor = Col.greenAccent;
        backgroundColor = Col.greenAccent.withOpacity(0.1);
        break;
      case 'Edit Produk':
        iconData = FontAwesomeIcons.filePen;
        iconColor = Col.orangeAccent;
        backgroundColor = Col.orangeAccent.withOpacity(0.1);
        break;
      case 'Update Stok':
        iconData = FontAwesomeIcons.penToSquare;
        iconColor = Col.primaryColor;
        backgroundColor = Col.primaryColor.withOpacity(0.1);
        break;
      case 'Hapus Produk':
        iconData = FontAwesomeIcons.cartArrowDown;
        iconColor = Col.redAccent;
        backgroundColor = Col.redAccent.withOpacity(0.1);
        break;
      case 'Pengeluaran':
        iconData = FontAwesomeIcons.circleArrowUp;
        iconColor = Col.redAccent;
        backgroundColor = Col.redAccent.withOpacity(0.1);
        break;
      case 'Pemasukan':
        iconData = FontAwesomeIcons.circleArrowDown;
        iconColor = Col.greenAccent;
        backgroundColor = Col.greenAccent.withOpacity(0.1);
        break;
      default:
        iconData = FontAwesomeIcons.circleInfo;
        iconColor = Col.greyColor;
        backgroundColor = Col.greyColor.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: FaIcon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }
}
