import 'package:flutter/services.dart';

class NoLeadingZeroTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith('0')) {
      return TextEditingValue(text: "");
    }
    return newValue;
  }
}
