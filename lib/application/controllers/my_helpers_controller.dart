import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHelpersController {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchAyudantes() async {
    try {
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
        if (solicitudDoc.exists) {
          data['solicitud'] = solicitudDoc.data();
        }

        final helperId = data['helperId'];
        if (helperId != null && helperId.toString().trim().isNotEmpty) {
          final helperDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(helperId)
              .get();

          if (helperDoc.exists) {
            data['helper'] = helperDoc.data();
          } else {
            data['helper'] = {}; 
          }
        } else {
          data['helper'] = {};
        }

        ayudantes.add(data);
      }

      return ayudantes;
    } catch (e) {
      print('Error al obtener ayudantes: $e');
      rethrow;
    }
  }

  Future<void> despedirAyudante(String postulacionId) async {
    await FirebaseFirestore.instance
        .collection('postulaciones')
        .doc(postulacionId)
        .update({'estado': 'despedido'});
  }
}
