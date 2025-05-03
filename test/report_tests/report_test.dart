import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../repository/Image_service.dart';

class FakeUploader implements CloudImageUploader {
  @override
  Future<String> upload(File file) async => 'https://img.fake/test.jpg';
}

void main() {
  group('TaskImageService.uploadTaskImage()', () {
    late FakeFirebaseFirestore firestore;
    late TaskImageService service;
    late String taskId;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = TaskImageService(
        firestore: firestore,
        uploader: FakeUploader(),
      );


      final doc =
      await firestore.collection('tareas').add({'descripcion': 'Limpieza'});
      taskId = doc.id;
    });

    test('sube imagen y guarda la URL en Firestore', () async {

      final tempFile = File('dummy.jpg')..writeAsStringSync('x');

      await service.uploadTaskImage(file: tempFile, taskId: taskId);

      final snap =
      await firestore.collection('tareas').doc(taskId).get();
      expect(snap['imagen'], 'https://img.fake/test.jpg');
    });
  });
}
