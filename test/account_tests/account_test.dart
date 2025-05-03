import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../repository/account_service.dart';


class TestUser extends MockUser {
  TestUser({required String uid, required String email})
      : super(uid: uid, email: email);


  @override
  Future<void> updateEmail(String newEmail) async {
    email = newEmail;
  }

  @override
  Future<void> updatePassword(String newPassword) async {

  }
}

void main() {
  /* Binding y FirebaseApp en memoria */
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async => await Firebase.initializeApp());

  /* --------------------------- changeEmail() --------------------------- */
  group('AccountService.changeEmail()', () {
    late MockFirebaseAuth authMock;
    late AccountService   service;

    setUp(() async {
      authMock = MockFirebaseAuth(
        mockUser: TestUser(uid: 'uOld', email: 'old@test.com'),
      );
      service = AccountService(authInstance: authMock);
    });

    test('cambia email cuando todo es correcto', () async {
      await service.changeEmail(
        newEmail: 'new@test.com',
        currentPassword: 'pwd',
      );

      expect(authMock.currentUser!.email, 'new@test.com');
    });

    test('lanza email-already-in-use si otra cuenta tiene el correo', () async {
      await authMock.createUserWithEmailAndPassword(
        email: 'dup@test.com',
        password: '123',
      );

      expect(
            () => service.changeEmail(
          newEmail: 'dup@test.com',
          currentPassword: 'pwd',
        ),
        throwsA(isA<auth.FirebaseAuthException>()
            .having((e) => e.code, 'code', 'email-already-in-use')),
      );
    });

    test('lanza wrong-password si contraseña es incorrecta', () async {
      expect(
            () => service.changeEmail(
          newEmail: 'other@test.com',
          currentPassword: 'wrong', // distinta de 'pwd'
        ),
        throwsA(isA<auth.FirebaseAuthException>()
            .having((e) => e.code, 'code', 'wrong-password')),
      );
    });
  });

  /* -------------------------- changePassword() -------------------------- */
  group('AccountService.changePassword()', () {
    test('actualiza contraseña tras reautenticarse', () async {
      final authMock = MockFirebaseAuth(
        mockUser: TestUser(uid: 'u1', email: 'user@test.com'),
      );
      final service = AccountService(authInstance: authMock);

      await service.changePassword(oldPassword: 'pwd', newPassword: 'new123');
      // si no se lanza excepción, se considera éxito
      expect(true, isTrue);
    });

    test('lanza wrong-password si oldPassword es incorrecta', () async {
      final authMock = MockFirebaseAuth(
        mockUser: TestUser(uid: 'u2', email: 'fail@test.com'),
      );
      final service = AccountService(authInstance: authMock);

      expect(
            () => service.changePassword(oldPassword: 'bad', newPassword: 'x'),
        throwsA(isA<auth.FirebaseAuthException>()
            .having((e) => e.code, 'code', 'wrong-password')),
      );
    });
  });
}




