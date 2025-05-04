import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import '../repository/solicitud_repository.dart';
import '../repository/task_manager.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('TaskManager.addTask()', () {
    test('agrega a Cuidados y marca flag', () {
      final mgr = TaskManager();
      mgr.addTask('Cuidados', 'Adultos mayores');

      expect(mgr.cuidados, contains('Adultos mayores'));
      expect(mgr.addedCuidados['Adultos mayores'], isTrue);
      expect(mgr.hogar, isEmpty);
    });

    test('agrega a Hogar y marca flag', () {
      final mgr = TaskManager();
      mgr.addTask('Hogar', 'Limpieza');

      expect(mgr.hogar, contains('Limpieza'));
      expect(mgr.addedHogar['Limpieza'], isTrue);
      expect(mgr.cuidados, isEmpty);
    });
  });

  group('SolicitudRepository.createSolicitud()', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late SolicitudRepository repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'test@test.com'),
      );
      repo = SolicitudRepository(
        firestore: firestore,
        authInstance: mockAuth,
      );
    });

    test('crea documento con los campos correctos', () async {
      final tasks = {
        'cuidados': ['Adultos mayores'],
        'hogar': ['Limpieza'],
      };

      final id = await repo.createSolicitud(
        tasks: tasks,
        periodicidad: 'semanal',
        cantidad: 1500,
        inicio: DateTime(2025, 5, 3),
        fin: DateTime(2025, 5, 10),
      );

      final snap =
      await firestore.collection('solicitudes').doc(id).get();

      expect(snap.exists, isTrue);
      expect(snap['uid'], 'u1');
      expect(snap['tasks']['hogar'], contains('Limpieza'));
      expect(snap['periodicidad_pago'], 'semanal');
      expect(snap['cantidad_pago'], 1500);
      expect(snap['tiene_contrato'], isFalse);
    });
  });
}
