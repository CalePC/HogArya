import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final FirebaseFirestore _db;
  CommentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> submitComment({
    required String tareaId,
    required String helperId,
    required String comment,
  }) async {
    final text = comment.trim();
    if (text.isEmpty) {
      throw ArgumentError('comment-empty');
    }

    await _db.collection('comentarios').add({
      'tareaId': tareaId,
      'helperId': helperId,
      'comentario': text,
      'fecha': Timestamp.now(),
    });

    await _db.collection('notificaciones').add({
      'helperId': helperId,
      'mensaje': 'Nuevo comentario sobre tu tarea.',
      'fecha': Timestamp.now(),
    });
  }
}
