import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';

class IconTextButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback onPressed;
  final bool iconOnRight;
  final double iconSize;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  const IconTextButton({
    super.key,
    required this.text,
    required this.iconData,
    required this.onPressed,
    this.iconOnRight = false,
    this.iconSize = 24.0,
    this.textColor = Col.blackColor,
    this.iconColor = Col.blackColor,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Col.blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
          (states) => const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        // side: MaterialStateProperty.all<BorderSide>(
        //   BorderSide(color: borderColor, width: 1.0),
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!iconOnRight) _buildIcon(),
          Padding(
            padding: EdgeInsets.only(
                left: iconOnRight ? 8.0 : 5.0, right: iconOnRight ? 5.0 : 8.0),
            child: Text(text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                )),
          ),
          if (iconOnRight) _buildIcon(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      iconData,
      size: iconSize,
      color: iconColor,
    );
  }
}
