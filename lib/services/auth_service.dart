import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTRO
  Future<User?> register(String email, String password, String name) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid;

      // Guardar en Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user', // puedes luego cambiar con custom claims
      });

      return userCred.user;
    } catch (e) {
      print('❌ Error al registrar: $e');
      rethrow;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print('❌ Error al iniciar sesión: $e');
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // USUARIO ACTUAL
  User? get currentUser => _auth.currentUser;
}
