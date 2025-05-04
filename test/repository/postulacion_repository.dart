import 'package:cloud_firestore/cloud_firestore.dart';

class PostulacionRepository {
  final FirebaseFirestore _db;
  PostulacionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

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

  Future<void> acceptPostulation({
    required String postId,
    required String helperId,
    required String solicitudId,
  }) async {
    await _db.collection('postulaciones').doc(postId).update({
      'estado': 'aceptado',
    });

    final tasksSnap = await _db
        .collection('tareas')
        .where('solicitudId', isEqualTo: solicitudId)
        .get();

    for (final doc in tasksSnap.docs) {
      await doc.reference.update({'helperId': helperId});
    }
  }
}

