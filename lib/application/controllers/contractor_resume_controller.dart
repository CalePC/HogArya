import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContractorResumeController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchTodayTasks() async {
    if (uid == null) return [];

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final query = await _db
        .collection('tareas')
        .where('contratanteId', isEqualTo: uid)
        .where('fecha', isGreaterThanOrEqualTo: start)
        .where('fecha', isLessThan: end)
        .orderBy('fecha', descending: true)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['fecha'] as Timestamp?;
      return {
        'taskId': doc.id,
        'descripcion': data['descripcion'] ?? 'Sin descripción',
        'imagen': data['imagen'] ?? '',
        'completada': data['completada'] ?? false,
        'fecha': timestamp != null
            ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
            : 'Hora no disponible',
        'helperId': data['helperId'] ?? '',
      };
    }).toList();
  }

  Future<void> marcarComoCompletada(String taskId) async {
    await _db.collection('tareas').doc(taskId).update({'completada': true});
  }
}
