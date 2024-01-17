import 'package:flutter/material.dart';

class DesignSystem {
  static const Color primaryColor = Color(0xFF2A60FF);
  static const Color secondaryColor = Color(0xFFf9fafc);
  // static const Color secondaryColor = Color(0xFFF9F8FD);

  static const Color blackColor = Color(0xFF161515);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Colors.grey;
  static const Color purpleAccent = Colors.purple;
  static const Color redAccent = Colors.red;
  static const Color orangeAccent = Colors.orange;
  static const Color greenAccent = Colors.green;
  static const Color backgroundColor = Color(0xFFeeeff2);

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.bold;

  static const TextStyle titleTextStyle = TextStyle(
    color: DesignSystem.blackColor,
    fontSize: 16,
    fontFamily: 'Roboto',
    fontWeight: DesignSystem.bold,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    color: DesignSystem.blackColor,
    fontSize: 14,
    fontFamily: 'Roboto',
    fontWeight: DesignSystem.medium,
  );

  static const TextStyle headingTextStyle = TextStyle(
    color: DesignSystem.blackColor,
    fontSize: 20,
    fontFamily: 'Roboto',
    fontWeight: DesignSystem.bold,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    color: DesignSystem.blackColor,
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: DesignSystem.regular,
  );

  static const TextStyle emphasizedBodyTextStyle = TextStyle(
    color: DesignSystem.blackColor,
    fontFamily: 'Roboto',
    fontSize: 14,
    fontWeight: DesignSystem.medium,
  );
}
