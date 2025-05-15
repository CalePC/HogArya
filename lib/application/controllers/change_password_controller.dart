import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordController {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> changePassword({
    required BuildContext context,
    required VoidCallback onSuccess,
    required VoidCallback onStartLoading,
    required VoidCallback onEndLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) return;

    onStartLoading();

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: oldPassword.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword.text.trim());

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente.')),
      );
      onSuccess();
    } catch (e) {
    String errorMessage = 'Ocurrió un error. Intente nuevamente.';

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'La contraseña actual es incorrecta.';
          break;
      
        case 'weak-password':
          errorMessage = 'La nueva contraseña es demasiado débil.';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
      onEndLoading();
    }
  }

  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
  }

  String? validateOldPassword(String? value) {
  if (value == null || value.isEmpty) return 'Campo obligatorio';
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) return 'Campo obligatorio';
  if (value.length < 6) return 'Mínimo 6 caracteres';
  if (value == oldPassword.text) return 'La nueva contraseña no puede ser igual a la anterior';
  return null;
}

String? validateConfirmPassword(String? value) {
  if (value == null || value.isEmpty) return 'Campo obligatorio';
  if (value != newPassword.text) return 'Las contraseñas no coinciden';
  return null;
}
}
