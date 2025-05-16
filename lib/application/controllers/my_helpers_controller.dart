import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHelpersController {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchAyudantes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('postulaciones')
        .where('contractorId', isEqualTo: uid)
        .where('estado', isEqualTo: 'aceptado')
        .get();

    List<Map<String, dynamic>> ayudantes = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      final solicitudDoc = await FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(data['solicitudId'])
          .get();
      final solicitudData = solicitudDoc.data();
      if (solicitudData != null) {
        data['solicitud'] = solicitudData;
      }

      final helperDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(data['helperId'])
          .get();
      final helperData = helperDoc.data();
      if (helperData != null) {
        data['helper'] = helperData;
      }

      ayudantes.add(data);
    }

    return ayudantes;
  }

  Future<void> despedirAyudante(String postulacionId) async {
    await FirebaseFirestore.instance
        .collection('postulaciones')
        .doc(postulacionId)
        .update({'estado': 'despedido'});
  }
}
