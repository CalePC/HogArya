import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailsController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchRequestData(String requestId) async {
    final doc = await _db.collection('solicitudes').doc(requestId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<Map<String, dynamic>?> fetchContractorData(String contractorId) async {
    final doc = await _db.collection('usuarios').doc(contractorId).get();
    return doc.exists ? doc.data() : null;
  }
}
