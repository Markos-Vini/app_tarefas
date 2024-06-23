import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/screens/task_form_screen.dart';

void main() {
   setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
   });
  testWidgets('Date selection widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TaskFormScreen(),
    ));

    // Encontra o widget ListTile de seleção de data pelo ícone
    var dateTile = find.byWidgetPredicate((widget) => widget is ListTile && widget.leading is Icon && (widget.leading as Icon).icon == Icons.calendar_today);

    // Simula um toque no ListTile para abrir o seletor de data
    await tester.tap(dateTile);
    await tester.pump(); // Atualiza o widget após o toque

    // Verifica se o seletor de data está visível na interface
    expect(find.byType(AlertDialog), findsOneWidget);

    // Simula a seleção de uma data
    await tester.tap(find.text('OK'));
    await tester.pump();

    // Verifica se a data selecionada é exibida corretamente no widget
    expect(find.text(RegExp(r'\d{2}/\d{2}/\d{4}') as String), findsOneWidget);
  });
}
