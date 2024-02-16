import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

class CategoryIcon extends StatelessWidget {
  final String? category;

  const CategoryIcon({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return const SizedBox();
    }

    String imagePath;
    Color iconColor;

    switch (category) {
      case 'Dana':
        imagePath = 'images/dana.png';
        iconColor = Col.primaryColor;

        break;
      default:
        return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        imagePath,
        color: iconColor,
        width: 18,
        height: 18,
      ),
    );
  }
}
