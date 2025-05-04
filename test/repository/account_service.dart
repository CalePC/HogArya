import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSkills(List<String> selectedSkills) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in.");
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
      'habilidades': selectedSkills,
    });
  }

  Future<void> deleteUser(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      throw Exception("User not logged in.");
    }

    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Incorrect password.");
      }
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    if (user.email == null) {
      throw Exception("Cannot change password for user without email.");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to change password: ${e.toString()}");
    }
  }

  // Método previo para cambiar el email
  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updateEmail(newEmail);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to change email: ${e.toString()}");
    }
  }
}

