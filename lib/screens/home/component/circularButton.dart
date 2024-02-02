import 'package:flutter/material.dart';
import 'package:kajur_app/design/system.dart';

Widget buildCircularButton(
    BuildContext context, String label, IconData icon, Widget screen) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  width: 1,
                  color: Color(0x309E9E9E),
                )))),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(16.0),
        onPressed: () {
          // Handle button tap
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        icon: Icon(icon),
        iconSize: 28,
        color: Col.primaryColor,
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Col.greyColor),
      ),
    ],
  );
}
