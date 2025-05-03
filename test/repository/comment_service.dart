// lib/data/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final FirebaseFirestore _db;
  CommentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Valida y guarda el comentario; además genera la notificación.
  Future<void> submitComment({
    required String tareaId,
    required String helperId,
    required String comment,
  }) async {
    final text = comment.trim();
    if (text.isEmpty) {
      throw ArgumentError('comment-empty');
    }

    // 1. Comentario
    await _db.collection('comentarios').add({
      'tareaId': tareaId,
      'helperId': helperId,
      'comentario': text,
      'fecha': Timestamp.now(),
    });

    // 2. Notificación
    await _db.collection('notificaciones').add({
      'helperId': helperId,
      'mensaje': 'Nuevo comentario sobre tu tarea.',
      'fecha': Timestamp.now(),
    });
  }
}
