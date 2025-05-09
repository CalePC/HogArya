import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class ImageUploader {
  final cloudinary = CloudinaryPublic(
    'dpct1rohg', // <-- reemplaza con tu Cloud Name
    'Prueba', // <-- reemplaza con tu Upload Preset
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error al subir imagen a Cloudinary: $e');
      return null;
    }
  }
}
