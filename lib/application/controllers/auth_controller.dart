import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/screens/contractor/redirection_driver.dart';
import '../../presentation/screens/helper/helpers_screen.dart';
import '../../presentation/screens/super/super_user_screen.dart';
import '../../presentation/screens/register_account_screen.dart';
import '../../presentation/screens/register_profile_screen.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
    required Function(String) onError,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _db.collection('usuarios').doc(uid).get();
      final role = doc['rol'];

      if (!context.mounted) return;

      Widget nextScreen;
      if (role == 'helper') {
        nextScreen = const HelpersScreen();
      } else if (role == 'contractor') {
        nextScreen = const RedirectionDriver();
      } else if (role == 'super') {
        nextScreen = const SuperUserScreen();
      } else {
        onError('Rol desconocido.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? 'Error al iniciar sesión');
    }
  }

  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterAccountScreen()),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterProfileScreen(),
            settings: RouteSettings(arguments: result),
          ),
        );
      }
    });
  }
}
