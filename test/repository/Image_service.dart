
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

abstract class CloudImageUploader {

  Future<String> upload(File file);
}


class CloudinaryImageUploader implements CloudImageUploader {
  final CloudinaryPublic _client;
  CloudinaryImageUploader(this._client);

  @override
  Future<String> upload(File file) async {
    final res = await _client.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return res.secureUrl;
  }
}

class TaskImageService {
  final FirebaseFirestore _db;
  final CloudImageUploader _uploader;
  TaskImageService({
    FirebaseFirestore? firestore,
    CloudImageUploader? uploader,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _uploader = uploader ?? CloudinaryImageUploader(
          CloudinaryPublic('dpct1rohg', 'Prueba', cache: false),
        );

  Future<void> uploadTaskImage({
    required File file,
    required String taskId,
  }) async {
    final url = await _uploader.upload(file);
    await _db.collection('tareas').doc(taskId).update({'imagen': url});
  }
}
