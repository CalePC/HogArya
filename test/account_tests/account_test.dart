import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import '../repository/account_service.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('UserService', () {


    late MockFirebaseAuth authMock;
    late AccountService accountService;
    late MockUser testUser;

    setUp(() {
      testUser = MockUser(uid: 'test_uid', email: 'testuser@example.com');
      authMock = MockFirebaseAuth(mockUser: testUser);
      accountService = AccountService();
    });

    group('saveSkills()', () {
      test('guardar las nuevas habilidades', () async {

        final user = authMock.currentUser;

        final selectedSkills = ['Limpieza', 'Alimentación'];

        final instance = FakeFirebaseFirestore();

        await instance.collection('usuarios').doc(testUser.uid).set({'habilidades': []});
        await instance.collection('usuarios').doc(testUser.uid).update({
          'habilidades': selectedSkills,
        });

        final doc = await instance.collection('usuarios').doc(testUser.uid).get();
        expect(doc.data()?['habilidades'], selectedSkills);
      });
    });

    group('deleteUser()', () {
      test('borrar al usuario despues de la auth', () async {
        final password = 'contrasena';
        final credential = EmailAuthProvider.credential(email: 'testuser@example.com', password: password);

        when(authMock.currentUser!.reauthenticateWithCredential(credential))
            .thenAnswer((_) => Future.value());

        await accountService.deleteUser(password);

        verify(authMock.currentUser!.delete()).called(1);
      });

      test('manda error por contraseña incorrecta', () async {
        final password = 'incorrect_password';
        final credential = EmailAuthProvider.credential(email: 'testuser@example.com', password: password);

        when(authMock.currentUser!.reauthenticateWithCredential(credential))
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));

        expect(() async => await accountService.deleteUser(password),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Incorrect password'))));
      });

      test('manda error por no estar logeado', () async {
        authMock = MockFirebaseAuth();
        accountService = AccountService();

        expect(() async => await accountService.deleteUser('password'),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('User not logged in'))));
      });
    });

    group('changeEmail()', () {
      test('cambiar correo', () async {
        await accountService.changeEmail(
          newEmail: 'newemail@example.com',
          currentPassword: 'password',
        );

        expect(authMock.currentUser!.email, equals('newemail@example.com'));
      });

      test('manda error por contraseña incorrecta', () async {
        expect(
              () => accountService.changeEmail(
            newEmail: 'otheremail@example.com',
            currentPassword: 'wrongpassword',
          ),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to change email'))),
        );
      });

      test('manda error por no estar logeado', () async {
        authMock = MockFirebaseAuth();
        accountService = AccountService();

        expect(
              () => accountService.changeEmail(newEmail: 'newemail@example.com', currentPassword: 'password'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('User not logged in'))),
        );
      });
    });

    group('changePassword()', () {
      test('cambiar contraseña', () async {
        await accountService.changePassword(
          oldPassword: 'password',
          newPassword: 'newpassword123',
        );

        expect(true, isTrue);
      });

      test('error por contraseña incorrecta', () async {
        expect(
              () => accountService.changePassword(
            oldPassword: 'wrongpassword',
            newPassword: 'newpassword123',
          ),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to change password'))),
        );
      });

      test('manda error por no estar logeado', () async {
        authMock = MockFirebaseAuth();
        accountService = AccountService();

        expect(() async => await accountService.changePassword(oldPassword: 'password', newPassword: 'newpassword123'),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('User not logged in'))));
      });
    });
  });
}




