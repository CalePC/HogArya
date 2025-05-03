
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AccountService {
  final auth.FirebaseAuth _auth;
  AccountService({auth.FirebaseAuth? authInstance})
      : _auth = authInstance ?? auth.FirebaseAuth.instance;


  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('no-user');
    if (newEmail.trim() == user.email) throw ArgumentError('same-email');


    final methods = await _auth.fetchSignInMethodsForEmail(newEmail);
    if (methods.isNotEmpty) {
      throw auth.FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Email en uso',
      );
    }


    final cred = auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);


    await user.updateEmail(newEmail);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('no-user');

    final cred = auth.EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }
}
