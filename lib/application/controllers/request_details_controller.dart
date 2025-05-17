import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestDetailsController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchRequestData(String requestId) async {
    final doc = await _db.collection('solicitudes').doc(requestId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<Map<String, dynamic>?> fetchContractorData(String contractorId) async {
    final doc = await _db.collection('usuarios').doc(contractorId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<bool> hasAlreadyApplied(String solicitudId) async {
    final helperId = _auth.currentUser!.uid;
    final query = await _db
        .collection('postulaciones')
        .where('solicitudId', isEqualTo: solicitudId)
        .where('helperId', isEqualTo: helperId)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> postularAOferta(String solicitudId) async {
    final helperId = _auth.currentUser!.uid;
    await _db.collection('postulaciones').add({
      'solicitudId': solicitudId,
      'helperId': helperId,
      'estado': 'pendiente',
      'contraoferta': 0,
    });
  }
}
