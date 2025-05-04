import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../repository/auth_repository.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  group('CU01 – AuthRepository.loginAndGetRole()', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth mockAuth;
    late AuthRepository repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockAuth  = MockFirebaseAuth();
      repo      = AuthRepository(
        authInstance: mockAuth,
        firestoreInstance: firestore,
      );
    });

    Future<void> _createUser({
      required String email,
      required String password,
      required String role,
    }) async {
      final cred = await mockAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await firestore
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({'rol': role});
    }

    test('devuelve el rol correcto', () async {
      await _createUser(
        email: 'alice@test.com',
        password: 'pwd',
        role: 'helper',
      );

      final role = await repo.loginAndGetRole(
        email: 'alice@test.com',
        password: 'pwd',
      );

      expect(role, equals('helper'));
    });

    test('propaga FirebaseAuthException (credenciales erróneas)', () async {
      await _createUser(
        email: 'bob@test.com',
        password: 'pwd',
        role: 'contractor',
      );

      expect(
            () => repo.loginAndGetRole(
          email: 'bob@test.com',
          password: 'wrong',
        ),
        throwsA(isA<auth.FirebaseAuthException>()),
      );
    });

    test('lanza StateError si el doc no tiene rol', () async {
      final cred = await mockAuth.createUserWithEmailAndPassword(
          email: 'noRole@test.com', password: 'pwd');
      await firestore.collection('usuarios').doc(cred.user!.uid).set({});

      expect(
            () => repo.loginAndGetRole(
          email: 'noRole@test.com',
          password: 'pwd',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('AuthRepository.logout()', () {
    test('cierra la sesión y currentUser queda null', () async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'test@test.com'),
      );
      final repo = AuthRepository(authInstance: mockAuth);
      await repo.logout();

      expect(mockAuth.currentUser, isNull);
    });
  });
}
