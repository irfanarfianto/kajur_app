import 'package:flutter/material.dart';


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
        iconData = Icons.add;
        iconColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'Edit Produk':
        iconData = Icons.edit;
        iconColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'Hapus Produk':
        iconData = Icons.delete;
        iconColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      default:
        iconData = Icons.error;
        iconColor = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
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
