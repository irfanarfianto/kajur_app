import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove non-numeric characters from the input string
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Parse the numeric string to a double
    double value = double.tryParse(numericString) ?? 0.0;

    // Format the double value as currency
    final money =
        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    String formattedValue = money.format(value);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
