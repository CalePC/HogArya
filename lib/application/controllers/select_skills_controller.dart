import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectSkillsController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<String>> getHabilidadesUsuario() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return [];

    final habilidades = doc.data()?['habilidades'] as List<dynamic>? ?? [];
    return habilidades.cast<String>();
  }

  Future<void> guardarHabilidades(List<String> habilidades) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('usuarios').doc(uid).update({
      'habilidades': habilidades,
    });
  }
}
