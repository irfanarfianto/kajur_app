import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class TransaksiIcon extends StatelessWidget {
  final String? transactionType;

  const TransaksiIcon({super.key, required this.transactionType});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (transactionType) {
      case 'Pengeluaran':
        iconData = Icons.north_east;
        iconColor = Col.redAccent;
        backgroundColor = Col.redAccent.withOpacity(0.1);
        break;
      case 'Pemasukan':
        iconData = Icons.south_west;
        iconColor = Col.greenAccent;
        backgroundColor = Col.greenAccent.withOpacity(0.1);
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
