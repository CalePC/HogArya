import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../repository/postulacion_repository.dart';   // ajusta ruta

void main() {
  group('PostulacionRepository.acceptPostulation()', () {
    late FakeFirebaseFirestore firestore;
    late PostulacionRepository repo;
    late String tarea1;
    late String tarea2;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      repo = PostulacionRepository(firestore: firestore);
      
      await firestore.collection('postulaciones').doc('post1').set({
        'solicitudId': 'sol001',
        'helperId': 'helperX',
        'estado': 'pendiente',
      });

      tarea1 = (await firestore.collection('tareas').add({
        'solicitudId': 'sol001',
        'descripcion': 'Limpieza',
      }))
          .id;

      tarea2 = (await firestore.collection('tareas').add({
        'solicitudId': 'sol001',
        'descripcion': 'Cocina',
      }))
          .id;
    });

    test('cambia estado a aceptado y asigna helperId a tareas', () async {
      await repo.acceptPostulation(
        postId: 'post1',
        helperId: 'helperX',
        solicitudId: 'sol001',
      );

      // Verifica postulación
      final postSnap =
      await firestore.collection('postulaciones').doc('post1').get();
      expect(postSnap['estado'], 'aceptado');

      // Verifica tareas actualizadas
      final t1 =
      await firestore.collection('tareas').doc(tarea1).get();
      final t2 =
      await firestore.collection('tareas').doc(tarea2).get();
      expect(t1['helperId'], 'helperX');
      expect(t2['helperId'], 'helperX');
    });
  });
}
