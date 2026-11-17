import 'package:flutter/services.dart';

/// Teléfono de México: solo dígitos y como máximo 10. Misma regla que el
/// servidor (`normalize_mx_phone`) y la web (`frontend/src/utils/phone.js`).
const int phoneLength = 10;

/// Limpia lo que se escribe o se pega: quita letras, espacios y guiones, y
/// el "+52" de los contactos ("+52 55 1234 5678" -> "5512345678").
/// No se usa LengthLimitingTextInputFormatter solo porque cortaría el texto
/// pegado ANTES de quitar el +52.
String cleanPhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('52')) digits = digits.substring(2);
  return digits.length > phoneLength ? digits.substring(0, phoneLength) : digits;
}

class MxPhoneInputFormatter extends TextInputFormatter {
  const MxPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleaned = cleanPhone(newValue.text);
    if (cleaned == newValue.text) return newValue;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
