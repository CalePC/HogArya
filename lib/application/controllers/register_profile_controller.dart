import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterProfileController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String selectedRole = '';
  String selectedGender = 'Masculino';
  bool livesInCoatzacoalcos = false;

  bool isFormComplete() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;
    return name.isNotEmpty && age > 0 && selectedRole.isNotEmpty;
  }

  Future<void> finishRegistration({
    required BuildContext context,
    required Map<String, dynamic> args,
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    final uid = args['uid'];
    final email = args['email'];
    final password = args['password'];
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;

    if (selectedRole.isEmpty) {
      onError('Selecciona un rol antes de continuar');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nombre': name,
        'sexo': selectedGender,
        'rol': selectedRole,
        'edad': age,
        'viveEnCoatzacoalcos': livesInCoatzacoalcos,
        'email': email,
        'password': password,
      });

      onSuccess();
    } catch (_) {
      onError('Ocurrió un error al guardar tu información.');
    }
  }

  void dispose() {
    nameController.dispose();
    ageController.dispose();
  }
}
