import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateHelpersListController {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchHelpersWithRatings() async {
    final query = await _db
        .collection('postulaciones')
        .where('contractorId', isEqualTo: _uid)
        .where('estado', isEqualTo: 'aceptado')
        .get();

    List<Map<String, dynamic>> result = [];

    for (var doc in query.docs) {
      final data = doc.data();
      final helperId = data['helperId'];

      if (helperId == null || helperId == '') continue;

      final helperDoc = await _db.collection('usuarios').doc(helperId).get();
      if (!helperDoc.exists) continue;

      final helper = helperDoc.data();
      result.add({
        'helperId': helperId,
        'nombre': helper?['nombre'] ?? 'Sin nombre',
        'calificacionPromedio': helper?['calificacionPromedio'],
      });
    }

    return result;
  }
}
