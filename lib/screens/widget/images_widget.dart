import 'package:flutter/material.dart';

Widget buildImagesWidget(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Implementasikan logika untuk menampilkan gambar secara penuh (jika diperlukan)
        },
        child: const SizedBox(
          width: 200,
          height: 200,
          // child: Image.asset(
          //   'images/gambar.png',
          //   fit: BoxFit.cover,
          // ),
        ),
      ),
    ],
  );
}
