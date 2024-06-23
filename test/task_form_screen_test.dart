import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/screens/task_form_screen.dart';

void main() {
  group('TaskFormScreen', () {
    test('Empty name validation', () {
      var screen = TaskFormScreen();
      var result = screen.nameValidator(''); // Acessando o método público
      expect(result, 'Por favor, insira o nome da tarefa');
    });

    test('Non-empty name validation', () {
      var screen = TaskFormScreen();
      var result = screen.nameValidator('Task Name'); // Acessando o método público
      expect(result, null); // Deve retornar null se o nome for válido
    });
  });
}
