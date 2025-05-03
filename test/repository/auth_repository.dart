import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({
    auth.FirebaseAuth? authInstance,
    FirebaseFirestore? firestoreInstance,
  })  : _auth = authInstance ?? auth.FirebaseAuth.instance,
        _db = firestoreInstance ?? FirebaseFirestore.instance;

  /// CU01 – Iniciar sesión y obtener rol.
  /// Devuelve 'helper' | 'contractor' | 'super'
  Future<String> loginAndGetRole({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = cred.user!.uid;
    final snap = await _db.collection('usuarios').doc(uid).get();
    if (!snap.exists || !snap.data()!.containsKey('rol')) {
      throw StateError('El usuario no tiene rol asignado');
    }
    return snap['rol'] as String;
  }

  Future<void> logout() => _auth.signOut();
}
