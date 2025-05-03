import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

class AccountService {
  final auth.FirebaseAuth _auth;

  // Allow injecting FirebaseAuth instance for testing
  AccountService({@visibleForTesting auth.FirebaseAuth? authInstance})
      : _auth = authInstance ?? auth.FirebaseAuth.instance;

  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in."); // Or a specific exception
    }

    // Re-authenticate the user first
    final credential = auth.EmailAuthProvider.credential(
      email: user.email!, // Assume user has email
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      // If re-authentication is successful, update the email
      await user.updateEmail(newEmail);
      // Optional: Send verification email to the new address
      // await user.sendEmailVerification();
    } on auth.FirebaseAuthException {
      // Re-throw the exception to be handled by the caller
      rethrow;
    } catch (e) {
      // Handle other potential errors during re-auth or update
      throw Exception("Failed to change email: ${e.toString()}");
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

    final credential = auth.EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      // If re-authentication is successful, update the password
      await user.updatePassword(newPassword);
    } on auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to change password: ${e.toString()}");
    }
  }
}

