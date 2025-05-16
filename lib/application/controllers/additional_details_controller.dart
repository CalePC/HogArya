import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdditionalDetailsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> submitRequest({
    required Map<String, List<String>> tasks,
    required String selectedPeriod,
    required double cantidadPago,
    required DateTime? startDate,
    required DateTime? endDate,
    Map<String, dynamic>? editingRequest,
  }) async {
    final data = {
      'uid': uid,
      'tasks': tasks,
      'tiene_contrato': false,
      'periodicidad_pago': selectedPeriod,
      'cantidad_pago': cantidadPago,
      'fecha_inicio': startDate?.toIso8601String(),
      'fecha_fin': endDate?.toIso8601String(),
    };

    final solicitudId = editingRequest == null
        ? (await _db.collection('solicitudes').add(data)).id
        : editingRequest['id'];

    if (editingRequest != null) {
      await _db.collection('solicitudes').doc(solicitudId).update(data);
    }

    await _createTasksForDates(solicitudId, tasks, startDate, endDate);
  }

  Future<void> _createTasksForDates(
    String solicitudId,
    Map<String, List<String>> tasks,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    if (startDate == null || endDate == null) return;

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (!current.isAfter(lastDay)) {
      for (final entry in tasks.entries) {
        final tipo = entry.key;
        for (final descripcion in entry.value) {
          await _db.collection('tareas').add({
            'descripcion': descripcion,
            'tipo': tipo,
            'contratanteId': uid,
            'solicitudId': solicitudId,
            'fecha': Timestamp.fromDate(current),
            'fecha_creacion': Timestamp.now(),
            'imagen': '',
            'helperId': '',
          });
        }
      }
      current = current.add(const Duration(days: 1));
    }
  }
}
