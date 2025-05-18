import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> enviarReporte({
    required String helperId,
    required String motivo,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final existing = await FirebaseFirestore.instance
        .collection('reportes')
        .where('reportadoId', isEqualTo: helperId)
        .where('reportadorId', isEqualTo: uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ya has reportado a este ayudante.');
    }
    
    final contractorId = _auth.currentUser?.uid;
    if (contractorId == null) return;

    await _firestore.collection('reportes').add({
      'reportadoId': helperId,
      'reportanteId': contractorId,
      'motivo': motivo,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  
}
