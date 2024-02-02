import 'package:flutter/material.dart';

class Col {
  static const Color primaryColor = Color(0xFF2A60FF);
  static const Color secondaryColor = Color(0xFFf9fafc);
  // static const Color secondaryColor = Color(0xFFF9F8FD);

  static const Color blackColor = Color(0xFF161515);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color purpleAccent = Color(0xFF800080);
  static const Color redAccent = Color(0xFFFF0000);
  static const Color orangeAccent = Color(0xFFFFA500);
  static const Color greenAccent = Color(0xFF00FF00);
  static const Color backgroundColor = Color(0xFFeeeff2);
}

class Fw {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.bold;
}

class Typo {
  static const double _baseFontSize = 14.0;

  static TextStyle titleTextStyle = const TextStyle(
    fontSize: _baseFontSize + 2,
    fontWeight: Fw.bold,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: _baseFontSize,
    fontWeight: Fw.medium,
  );

  static const TextStyle headingTextStyle = TextStyle(
    fontSize: _baseFontSize + 6,
    fontWeight: Fw.bold,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: _baseFontSize,
    fontWeight: Fw.regular,
  );

  static const TextStyle emphasizedBodyTextStyle = TextStyle(
    fontSize: _baseFontSize,
    fontWeight: Fw.medium,
  );
}
