import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingsController {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<double> getPromedioCalificaciones() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final query = await _db
        .collection('calificaciones')
        .where('calificadoId', isEqualTo: uid)
        .get();

    if (query.docs.isEmpty) return 0;

    final ratings = query.docs
        .map((doc) => (doc['calificacion'] as num).toDouble())
        .toList();

    final double sum = ratings.fold(0.0, (a, b) => a + b);
    return sum / ratings.length;
  }


  Future<List<String>> getAreasDestacadas() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final query = await _db
        .collection('calificaciones')
        .where('calificadoId', isEqualTo: uid)
        .get();

    final contador = <String, int>{};

    for (var doc in query.docs) {
      final destacadas = List<String>.from(doc['areasDestacadas'] ?? []);
      for (var area in destacadas) {
        contador[area] = (contador[area] ?? 0) + 1;
      }
    }

    final sorted = contador.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }
}
