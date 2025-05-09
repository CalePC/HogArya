import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> register(String email, String password, String name) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCred.user?.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
      return userCred.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
