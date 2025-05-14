import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


//Todo este código es una kk, no sirve aún.
class ProfileController {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Subir imagen a Firebase Storage y obtener la URL
  Future<String?> uploadProfileImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Crear una referencia al almacenamiento de Firebase
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
      // Subir la imagen
      await storageRef.putFile(image);

      // Obtener la URL de la imagen subida
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  // Guardar la URL de la imagen de perfil en Firestore
  Future<void> saveProfileImageUrl(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'photoUrl': imageUrl,
      });
    } catch (e) {
      print("Error al guardar URL en Firestore: $e");
    }
  }

  // Cargar datos del usuario desde Firebase
  Future<Map<String, dynamic>?> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
