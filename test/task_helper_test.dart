import 'package:flutter_test/flutter_test.dart';
import 'package:my_custom_package/my_custom_package.dart';

void main() {
  group('TaskHelper', () {
    test('generateTaskId generates unique IDs', () {
      TaskHelper taskHelper = TaskHelper();

      // Gerar alguns IDs e verificar se são únicos
      String id1 = taskHelper.generateTaskId();
      String id2 = taskHelper.generateTaskId();
      String id3 = taskHelper.generateTaskId();

      expect(id1, isNotNull);
      expect(id2, isNotNull);
      expect(id3, isNotNull);

      expect(id1, isNot(id2));
      expect(id1, isNot(id3));
      expect(id2, isNot(id3));
    });

    test('generated IDs have the correct format', () {
      TaskHelper taskHelper = TaskHelper();

      String id = taskHelper.generateTaskId();

      // Verificar se o ID gerado está no formato esperado (pode variar conforme sua implementação)
      expect(id.length, equals(36)); // Por exemplo, UUIDs têm 36 caracteres
      expect(id.contains('-'), isTrue); // Verificar se contém hífens (se for o caso)
    });
  });
}
