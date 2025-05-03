// lib/data/postulacion_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostulacionRepository {
  final FirebaseFirestore _db;
  PostulacionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Paso 1 – Ayudante envía contra‑oferta
  Future<String> enviarContraoferta({
    required String solicitudId,
    required String helperId,
    required String contraofertaStr,
  }) async {
    final monto = double.tryParse(contraofertaStr) ?? 0.0;
    final ref = await _db.collection('postulaciones').add({
      'solicitudId': solicitudId,
      'helperId': helperId,
      'contraoferta': monto,
      'estado': 'pendiente',
      'fecha': Timestamp.now(),
    });
    return ref.id;
  }

  /// Paso 2 – Contratante acepta la postulación
  Future<void> acceptPostulation({
    required String postId,
    required String helperId,
    required String solicitudId,
  }) async {
    // 1. Postulación → aceptado
    await _db.collection('postulaciones').doc(postId).update({
      'estado': 'aceptado',
    });

    // 2. Todas las tareas ligadas a la solicitud reciben el helperId
    final tasksSnap = await _db
        .collection('tareas')
        .where('solicitudId', isEqualTo: solicitudId)
        .get();

    for (final doc in tasksSnap.docs) {
      await doc.reference.update({'helperId': helperId});
    }
  }
}

