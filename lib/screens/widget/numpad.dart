import 'package:flutter/material.dart';
import 'package:kajur_app/utils/design/system.dart';
import 'package:kajur_app/screens/widget/inputan_rupiah.dart';

class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;

  const NumPad({
    Key? key,
    this.buttonSize = 65,
    this.buttonColor = Col.secondaryColor,
    this.iconColor = Colors.amber,
    required this.delete,
    required this.onSubmit,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 1; i <= 3; i++)
              NumberButton(
                number: i,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 4; i <= 6; i++)
              NumberButton(
                number: i,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 7; i <= 9; i++)
              NumberButton(
                number: i,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Col.primaryColor.withOpacity(0.8),
                  elevation: 0,
                  disabledForegroundColor:
                      Col.primaryColor.withOpacity(0.8).withOpacity(0.38),
                  disabledBackgroundColor:
                      Col.primaryColor.withOpacity(0.8).withOpacity(0.12),
                  backgroundColor: Col.backgroundColor,
                  surfaceTintColor: Col.backgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                onPressed: () {
                  final newText = '${controller.text}000';
                  final formattedText = CurrencyInputFormatter()
                      .formatEditUpdate(TextEditingValue.empty,
                          TextEditingValue(text: newText))
                      .text;
                  controller.value = TextEditingValue(
                    text: formattedText,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: formattedText.length),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    '000',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Col.blackColor.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            NumberButton(
              number: 0,
              size: buttonSize,
              color: buttonColor,
              controller: controller,
            ),
            GestureDetector(
              onLongPress: () {
                controller.clear();
              },
              child: IconButton(
                padding: const EdgeInsets.all(16.0),
                onPressed: () {
                  delete();
                  // Format the amount after deleting a digit
                  final formattedText = CurrencyInputFormatter()
                      .formatEditUpdate(
                        TextEditingValue.empty,
                        TextEditingValue(text: controller.text),
                      )
                      .text;
                  controller.value = TextEditingValue(
                    text: formattedText,
                    selection: TextSelection.collapsed(
                      offset: formattedText.length,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.backspace,
                ),
                color: iconColor,
                iconSize: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => onSubmit(),
          child: const Text('Catat'),
        ),
      ],
    );
  }
}

class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;

  const NumberButton({
    super.key,
    required this.number,
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Col.primaryColor.withOpacity(0.8),
          elevation: 0,
          disabledForegroundColor:
              Col.primaryColor.withOpacity(0.8).withOpacity(0.38),
          disabledBackgroundColor:
              Col.primaryColor.withOpacity(0.8).withOpacity(0.12),
          backgroundColor: Col.backgroundColor,
          surfaceTintColor: Col.backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
        ),
        onPressed: () {
          final newText = controller.text + number.toString();
          controller.value = TextEditingValue(
            text: CurrencyInputFormatter()
                .formatEditUpdate(
                  TextEditingValue.empty,
                  TextEditingValue(text: newText),
                )
                .text,
            selection: TextSelection.fromPosition(
              TextPosition(
                  offset: (controller.text + number.toString()).length),
            ),
          );
        },
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              color: Col.blackColor.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
