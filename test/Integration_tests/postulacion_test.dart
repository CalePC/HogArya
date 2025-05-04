import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../repository/postulacion_repository.dart';

void main() {
  group('Flujo de integración de contraoferta en postulaciones', () {
    late FakeFirebaseFirestore firestore;
    late PostulacionRepository repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = PostulacionRepository(firestore: firestore);
    });

    test('Envía una contraoferta y la guarda correctamente en Firestore', () async {
      final id = await repo.enviarContraoferta(
        solicitudId: 'sol001',
        helperId: 'helper123',
        contraofertaStr: '1800.50',
      );

      final snap = await firestore.collection('postulaciones').doc(id).get();
      expect(snap.exists, isTrue);
      expect(snap['solicitudId'], 'sol001');
      expect(snap['helperId'], 'helper123');
      expect(snap['contraoferta'], 1800.50);
      expect(snap['estado'], 'pendiente');
    });

    test('Si el texto no es numérico, guarda 0.0 como contraoferta', () async {
      final id = await repo.enviarContraoferta(
        solicitudId: 'sol002',
        helperId: 'helperXYZ',
        contraofertaStr: 'abc',
      );

      final snap = await firestore.collection('postulaciones').doc(id).get();
      expect(snap['contraoferta'], 0.0);
    });
  });
}
