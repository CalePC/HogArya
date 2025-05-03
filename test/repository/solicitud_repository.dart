// lib/data/solicitud_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class SolicitudRepository {
  final FirebaseFirestore _db;
  final auth.FirebaseAuth _auth;
  SolicitudRepository({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? authInstance,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = authInstance ?? auth.FirebaseAuth.instance;

  Future<String> createSolicitud({
    required Map<String, List<String>> tasks,
    required String periodicidad,
    required double cantidad,
    DateTime? inicio,
    DateTime? fin,
  }) async {
    final uid = _auth.currentUser!.uid;

    final data = {
      'uid': uid,
      'tasks': tasks,
      'tiene_contrato': false,
      'periodicidad_pago': periodicidad,
      'cantidad_pago': cantidad,
      'fecha_inicio': inicio?.toIso8601String(),
      'fecha_fin': fin?.toIso8601String(),
    };

    final ref = await _db.collection('solicitudes').add(data);
    return ref.id;
  }
}
