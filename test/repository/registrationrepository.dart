import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationRepository {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  RegistrationRepository({
    auth.FirebaseAuth? authInstance,
    FirebaseFirestore? firestoreInstance,
  })  : _auth = authInstance ?? auth.FirebaseAuth.instance,
        _db = firestoreInstance ?? FirebaseFirestore.instance;

  Future<String> registerUser({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      throw StateError('Las contraseñas no coinciden');
    }
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return cred.user!.uid;
  }

  Future<String> finishRegistration({
    required String uid,
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String role,
    required bool livesInCoatzacoalcos,
  }) async {
    await _db.collection('usuarios').doc(uid).set({
      'nombre': name,
      'sexo': gender,
      'rol': role,
      'edad': age,
      'viveEnCoatzacoalcos': livesInCoatzacoalcos,
      'email': email,
      'password': password,
    });
    return role;
  }

  Future<void> saveSkills({
    required String uid,
    required List<String> skills,
  }) async {
    await _db.collection('usuarios').doc(uid).update({
      'habilidades': skills,
    });
  }
}
