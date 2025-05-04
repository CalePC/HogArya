import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../repository/comment_service.dart';

void main() {
  group('Flujo de integración de comentario y notificación', () {
    late FakeFirebaseFirestore firestore;
    late CommentService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = CommentService(firestore: firestore);
    });

    test('Crea un comentario y una notificación correctamente', () async {
      await service.submitComment(
        tareaId: 'tarea1',
        helperId: 'helper1',
        comment: '¡Buen trabajo!',
      );

      final comments = await firestore.collection('comentarios').get();
      expect(comments.docs.length, 1);
      expect(comments.docs.first['tareaId'], 'tarea1');
      expect(comments.docs.first['comentario'], '¡Buen trabajo!');

      final notifs = await firestore.collection('notificaciones').get();
      expect(notifs.docs.length, 1);
      expect(notifs.docs.first['helperId'], 'helper1');
      expect(notifs.docs.first['mensaje'], 'Nuevo comentario sobre tu tarea.');
    });

    test('Lanza error si el comentario está vacío', () async {
      expect(
            () => service.submitComment(
          tareaId: 'tarea1',
          helperId: 'helper1',
          comment: '   ',
        ),
        throwsArgumentError,
      );
    });
  });
}
