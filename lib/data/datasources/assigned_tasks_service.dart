import 'package:cloud_firestore/cloud_firestore.dart';

class AssignedTasksService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTasksForHelper(String helperId) async {
    try {
      final postulacionesSnap = await _db
          .collection('postulaciones')
          .where('helperId', isEqualTo: helperId)
          .where('estado', isEqualTo: 'aceptado')
          .get();

      final solicitudesIds = postulacionesSnap.docs
          .map((doc) => doc.data()['solicitudId'] as String)
          .toList();

      final List<Map<String, dynamic>> tareasAsignadas = [];

      for (String solicitudId in solicitudesIds) {
        final docSnap = await _db.collection('solicitudes').doc(solicitudId).get();
        final data = docSnap.data();
        if (data == null) continue;

        final inicio = (data['fecha_inicio'] as Timestamp?)?.toDate();
        final fin = (data['fecha_fin'] as Timestamp?)?.toDate();

        final cuidados = List<String>.from(data['tasks']?['cuidados'] ?? []);
        final hogar = List<String>.from(data['tasks']?['hogar'] ?? []);

        for (var tarea in [...cuidados, ...hogar]) {
          tareasAsignadas.add({
            'descripcion': tarea,
            'fecha_inicio': inicio,
            'fecha_fin': fin,
            'tipo': cuidados.contains(tarea) ? 'cuidados' : 'hogar',
          });
        }
      }

      return tareasAsignadas;
    } catch (e) {
      print("Error al obtener tareas asignadas: $e");
      return [];
    }
  }
}
