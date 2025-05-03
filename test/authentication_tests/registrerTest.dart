import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../repository/registrationrepository.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late RegistrationRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockAuth   = MockFirebaseAuth();
    repo       = RegistrationRepository(
      authInstance: mockAuth,
      firestoreInstance: firestore,
    );
  });

  /* ------------------- Paso 1 : registerUser() ------------------- */
  group('registerUser()', () {
    test('registra y devuelve uid', () async {
      final uid = await repo.registerUser(
        email: 'new@test.com',
        password: '123456',
        confirmPassword: '123456',
      );
      expect(uid, isNotEmpty);
      expect(mockAuth.currentUser!.uid, equals(uid));
    });

    test('lanza StateError si passwords no coinciden', () async {
      expect(
            () => repo.registerUser(
          email: 'fail@test.com',
          password: '123',
          confirmPassword: '456',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('propaga FirebaseAuthException (email duplicado)', () async {
      // Pre‑creamos un user con el mismo correo
      await mockAuth.createUserWithEmailAndPassword(
          email: 'dup@test.com', password: 'secret');

      expect(
            () => repo.registerUser(
          email: 'dup@test.com',
          password: 'secret',
          confirmPassword: 'secret',
        ),
        throwsA(isA<auth.FirebaseAuthException>()),
      );
    });
  });

  /* ------------------- Paso 2 : finishRegistration() -------------- */
  group('finishRegistration()', () {
    late String uid;

    setUp(() async {
      uid = await repo.registerUser(
        email: 'user@test.com',
        password: 'pwd',
        confirmPassword: 'pwd',
      );
    });

    test('guarda documento y devuelve rol helper', () async {
      final role = await repo.finishRegistration(
        uid: uid,
        email: 'user@test.com',
        password: 'pwd',
        name: 'Alice',
        age: 25,
        gender: 'F',
        role: 'helper',
        livesInCoatzacoalcos: true,
      );

      expect(role, 'helper');
      final snap =
      await firestore.collection('usuarios').doc(uid).get();
      expect(snap['nombre'], 'Alice');
      expect(snap['rol'], 'helper');
    });

    test('guarda documento y devuelve rol contractor', () async {
      final newUid = await repo.registerUser(
          email: 'cont@test.com', password: 'pwd', confirmPassword: 'pwd');

      final role = await repo.finishRegistration(
        uid: newUid,
        email: 'cont@test.com',
        password: 'pwd',
        name: 'Bob',
        age: 30,
        gender: 'M',
        role: 'contractor',
        livesInCoatzacoalcos: false,
      );

      expect(role, 'contractor');
      final snap =
      await firestore.collection('usuarios').doc(newUid).get();
      expect(snap['rol'], 'contractor');
    });
  });

  /* ------------------- Paso 3 : saveSkills() ---------------------- */
  group('saveSkills()', () {
    late String uid;

    setUp(() async {
      uid = await repo.registerUser(
        email: 'skill@test.com',
        password: 'pwd',
        confirmPassword: 'pwd',
      );
      await repo.finishRegistration(
        uid: uid,
        email: 'skill@test.com',
        password: 'pwd',
        name: 'Helper',
        age: 22,
        gender: 'F',
        role: 'helper',
        livesInCoatzacoalcos: true,
      );
    });

    test('actualiza lista de habilidades', () async {
      await repo.saveSkills(uid: uid, skills: ['Limpieza', 'Niños']);

      final snap =
      await firestore.collection('usuarios').doc(uid).get();
      expect(snap['habilidades'], containsAll(['Limpieza', 'Niños']));
    });
  });
}
