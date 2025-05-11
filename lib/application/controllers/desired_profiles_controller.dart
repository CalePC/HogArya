import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DesiredProfilesController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final query = await _db
        .collection('solicitudes')
        .where('uid', isEqualTo: uid)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPostulaciones(String solicitudId) async {
    final query = await _db
        .collection('postulaciones')
        .where('solicitudId', isEqualTo: solicitudId)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteRequest(String id) async {
    final tasksSnapshot = await _db
        .collection('tareas')
        .where('solicitudId', isEqualTo: id)
        .get();
    for (var doc in tasksSnapshot.docs) {
      await doc.reference.delete();
    }
    await _db.collection('solicitudes').doc(id).delete();
  }

  Future<void> acceptPostulation({
    required String postId,
    required String helperId,
    required String solicitudId,
  }) async {
    await _db.collection('postulaciones').doc(postId).update({
      'estado': 'aceptado',
      'contractorId': uid,
    });

    final tasksSnapshot = await _db
        .collection('tareas')
        .where('solicitudId', isEqualTo: solicitudId)
        .get();
    for (var doc in tasksSnapshot.docs) {
      await doc.reference.update({'helperId': helperId});
    }
  }

  Future<void> rejectPostulation(String postId) async {
    await _db.collection('postulaciones').doc(postId).update({
      'estado': 'rechazado',
    });
  }

  Future<String?> getHelperName(String helperId) async {
    final doc = await _db.collection('users').doc(helperId).get();
    if (!doc.exists) return null;
    return doc['nombre'];
  }
}
