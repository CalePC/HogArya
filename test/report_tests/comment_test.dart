import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';



import '../repository/comment_service.dart';

void main() {
  group('CommentService.submitComment()', () {
    late FakeFirebaseFirestore firestore;
    late CommentService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service   = CommentService(firestore: firestore);
    });

    test('crea comentario y notificación cuando el texto es válido', () async {
      await service.submitComment(
        tareaId: 'tarea1',
        helperId: 'helper1',
        comment: '¡Buen trabajo!',
      );

      final comments = await firestore.collection('comentarios').get();
      final notifs   = await firestore.collection('notificaciones').get();

      expect(comments.docs.length, 1);
      expect(notifs.docs.length, 1);

      expect(comments.docs.first['tareaId'], 'tarea1');
      expect(comments.docs.first['comentario'], '¡Buen trabajo!');
      expect(notifs.docs.first['helperId'], 'helper1');
      expect(notifs.docs.first['mensaje'],
          'Nuevo comentario sobre tu tarea.');
    });

    test('lanza ArgumentError si el comentario a vacio', () async {
      expect(
            () => service.submitComment(
          tareaId: 't2',
          helperId: 'h2',
          comment: '   ',
        ),
        throwsArgumentError,
      );
    });
  });
}
