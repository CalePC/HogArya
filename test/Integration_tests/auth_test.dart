import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import '../repository/auth_repository.dart';
import '../repository/registrationrepository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late AuthRepository authRepo;
  late RegistrationRepository registrationRepo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    authRepo = AuthRepository(authInstance: mockAuth, firestoreInstance: firestore);
    registrationRepo = RegistrationRepository(authInstance: mockAuth, firestoreInstance: firestore);
  });

  group('Flujo de integración de registro y login de usuario', () {
    test('Registro de usuario y login correctamente autenticado', () async {

      final uid = await registrationRepo.registerUser(
        email: 'testuser@test.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      await registrationRepo.finishRegistration(
        uid: uid,
        email: 'testuser@test.com',
        password: 'password123',
        name: 'Test User',
        age: 25,
        gender: 'F',
        role: 'helper',
        livesInCoatzacoalcos: true,
      );

      final role = await authRepo.loginAndGetRole(
        email: 'testuser@test.com',
        password: 'password123',
      );

      expect(role, 'helper');
      final userDoc = await firestore.collection('usuarios').doc(uid).get();
      expect(userDoc['rol'], 'helper');
      expect(userDoc['nombre'], 'Test User');
    });

    test('Autenticación falla con credenciales incorrectas', () async {
      await registrationRepo.registerUser(
        email: 'testuser@test.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(
            () => authRepo.loginAndGetRole(
          email: 'testuser@test.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<auth.FirebaseAuthException>()),
      );
    });
  });
}
