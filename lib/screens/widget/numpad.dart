import 'package:flutter/material.dart';

class CustomNumPad extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onClearPressed;

  const CustomNumPad({
    super.key,
    required this.controller,
    this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('0'),
            _buildNumberButton('Hapus', hasIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String text, {bool hasIcon = false}) {
    return ElevatedButton(
      onPressed: () {
        if (text == 'Hapus') {
          if (onClearPressed != null) {
            onClearPressed!();
          } else {
            if (controller.text.isNotEmpty) {
              controller.text =
                  controller.text.substring(0, controller.text.length - 1);
            }
          }
        } else {
          controller.text += text;
        }
      },
      style: ElevatedButton.styleFrom(
        padding: hasIcon
            ? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0)
            : const EdgeInsets.all(16.0), backgroundColor: hasIcon ? Colors.red : Colors.grey[300],
      ),
      child: hasIcon ? const Icon(Icons.backspace) : Text(text),
    );
  }
}
