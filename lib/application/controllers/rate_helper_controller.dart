import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateHelperController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitRating({
    required String helperId,
    required double rating,
    required List<String> areasDestacadas,
    String? comentarios,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db.collection('calificaciones').add({
      'calificadoId': helperId,
      'calificadorId': currentUserId,
      'calificacion': rating,
      'comentarios': comentarios ?? '',
      'areasDestacadas': areasDestacadas,
      'fecha': FieldValue.serverTimestamp(),
    });

    final helperDoc = await _db.collection('usuarios').doc(helperId).get();
    if (helperDoc.exists) {
      final data = helperDoc.data()!;
      final double currentAvg = (data['calificacionPromedio'] ?? 0).toDouble();
      final int totalRatings = (data['totalRatings'] ?? 0).toInt();

      final double newAvg = (currentAvg * totalRatings + rating) / (totalRatings + 1);

      await _db.collection('usuarios').doc(helperId).update({
        'calificacionPromedio': newAvg,
        'totalRatings': totalRatings + 1,
      });
    }
  }
}
