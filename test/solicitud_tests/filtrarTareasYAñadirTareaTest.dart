import 'package:flutter_test/flutter_test.dart';
import '../repository/task_manager.dart';

void main() {
  group('TaskManager vacío', () {
    late TaskManager manager;

    setUp(() => manager = TaskManager());

    test('addTask agrega a Cuidados y marca flag', () {
      manager.addTask('Cuidados', 'Adultos mayores');

      expect(manager.cuidados, contains('Adultos mayores'));
      expect(manager.addedCuidados['Adultos mayores'], isTrue);
      expect(manager.hogar, isEmpty);
    });

    test('addTask agrega a Hogar y marca flag', () {
      manager.addTask('Hogar', 'Limpieza');

      expect(manager.hogar, contains('Limpieza'));
      expect(manager.addedHogar['Limpieza'], isTrue);
      expect(manager.cuidados, isEmpty);
    });
  });

  group('TaskManager con solicitud pre‑existente', () {
    late TaskManager manager;

    setUp(() {
      final editingRequest = {
        'tasks': {
          'cuidados': ['Medicinas'],
          'hogar': ['Lavado de ropa'],
        }
      };
      manager = TaskManager(editingRequest: editingRequest);
    });

    test('inicializa listas y flags desde editingRequest', () {
      expect(manager.cuidados, contains('Medicinas'));
      expect(manager.hogar, contains('Lavado de ropa'));
      expect(manager.addedCuidados['Medicinas'], isTrue);
      expect(manager.addedHogar['Lavado de ropa'], isTrue);
    });

    test('addTask agrega nueva tarea a Cuidados', () {
      manager.addTask('Cuidados', 'Baño');

      expect(manager.cuidados,
          containsAll(<String>['Medicinas', 'Baño']));
      expect(manager.addedCuidados['Baño'], isTrue);
    });

    test('addTask agrega nueva tarea a Hogar', () {
      manager.addTask('Hogar', 'Cocina');

      expect(manager.hogar,
          containsAll(<String>['Lavado de ropa', 'Cocina']));
      expect(manager.addedHogar['Cocina'], isTrue);
    });
  });
}


