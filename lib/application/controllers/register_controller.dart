import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String error = '';

  bool isFormComplete() {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    return email.isNotEmpty && pass.isNotEmpty && confirm.isNotEmpty;
  }

  Future<Map<String, String>?> register(
    BuildContext context,
    void Function(String) onError,
  ) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password != confirm) {
      onError('Las contraseñas no coinciden');
      return null;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        return {
          'uid': user.uid,
          'email': email,
          'password': password,
        };
      }
    } on FirebaseAuthException catch (e) {
      final translated = translateFirebaseError(e.code);
      onError(translated);
    } catch (_) {
      onError('Error inesperado. Intenta más tarde.');
    }

    return null;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }

  String translateFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'operation-not-allowed':
        return 'Registro no habilitado. Contacta al soporte.';
      case 'network-request-failed':
        return 'Problema de conexión. Intenta nuevamente.';
      default:
        return 'Error inesperado. Intenta otra vez.';
    }
  }
}
