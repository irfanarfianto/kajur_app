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
              ),
            ))),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(16.0),
        onPressed: () {
          // Handle button tap
          Navigator.of(context).push(_createRoute(screen));
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

Route _createRoute(Widget screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.3);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    reverseTransitionDuration: const Duration(milliseconds: 100),
    transitionDuration: const Duration(milliseconds: 300),
  );
}
