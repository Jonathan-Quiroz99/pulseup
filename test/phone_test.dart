import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseup/core/phone.dart';

void main() {
  test('cleanPhone: solo dígitos, máximo 10, quita el +52', () {
    expect(cleanPhone('5512345678'), '5512345678');
    expect(cleanPhone('55a12b345678'), '5512345678');
    expect(cleanPhone('+52 55 1234 5678'), '5512345678');
    expect(cleanPhone('55123456789999'), '5512345678');
    expect(cleanPhone('(55) 1234-5678'), '5512345678');
  });

  testWidgets('el campo no deja escribir letras ni más de 10 números', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextField(controller: controller, inputFormatters: const [MxPhoneInputFormatter()]),
      ),
    ));
    await tester.enterText(find.byType(TextField), '55abc1234567899');
    expect(controller.text, '5512345678');
    await tester.enterText(find.byType(TextField), '+52 33 1234 5678');
    expect(controller.text, '3312345678');
  });
}
