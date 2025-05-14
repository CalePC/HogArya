import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HelpersController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.exists ? doc['rol'] : null;
  }

  Stream<List<Map<String, dynamic>>> getSolicitudesConDatosContractor() async* {
    final snapshots = _firestore.collection('solicitudes').snapshots();

    await for (final snapshot in snapshots) {
      final solicitudes = snapshot.docs;

      final enriched = await Future.wait(solicitudes.map((doc) async {
        final data = doc.data();
        final contractorId = data['uid'];
        Map<String, dynamic> contractorData = {};

        if (contractorId != null) {
          final contractorDoc = await _firestore.collection('usuarios').doc(contractorId).get();
          if (contractorDoc.exists) {
            contractorData = contractorDoc.data()!;
          }
        }

        return {
          'solicitudId': doc.id,
          'solicitud': data,
          'contractor': contractorData,
        };
      }));

      yield enriched;
    }
  }

  List<Map<String, dynamic>> filtrarSolicitudes(
    List<Map<String, dynamic>> items,
    List<String> selectedSkills,
  ) {
    if (selectedSkills.isEmpty) return items;

    return items.where((item) {
      final solicitud = item['solicitud'] as Map<String, dynamic>;
      final tasks = solicitud['tasks'] as Map<String, dynamic>? ?? {};
      final allTasks = <String>[
        ...(tasks['cuidados'] ?? []),
        ...(tasks['hogar'] ?? []),
      ].cast<String>().map((t) => t.toLowerCase());

      return selectedSkills.any((skill) => allTasks.contains(skill));
    }).toList();
  }

  Future<void> postularAOferta({
    required String solicitudId,
    required double contraoferta,
  }) async {
    final helperId = _auth.currentUser?.uid;
    if (helperId == null) return;

    await _firestore.collection('postulaciones').add({
      'solicitudId': solicitudId,
      'helperId': helperId,
      'contraoferta': contraoferta,
      'estado': 'pendiente',
      'fecha': Timestamp.now(),
      'contractorId': '',
    });
  }
}
