import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hogarya/presentation/screens/change_password_screen.dart';
import 'package:hogarya/presentation/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_header.dart';
import 'helper/select_skills_screen.dart';
import '../../application/controllers/profile_controller.dart'; 

class ProfileScreen extends StatefulWidget {
  final String role;

  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showPassword = false;
  Map<String, dynamic>? _userData;
  File? _profileImage;
  String? _profileImageUrl;
  final ProfileController _profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  
  Future<void> _loadUserData() async {
    final userData = await _profileController.loadUserData();
    setState(() {
      _userData = userData;
      _profileImageUrl = _userData?['photoUrl'];  
    });
  }

  
  Future<void> _pickImage() async {
    final image = await _profileController.pickImageFromGallery();
    if (image != null) {
      final imageUrl = await _profileController.uploadProfileImage(image);
      if (imageUrl != null) {
        setState(() {
          _profileImage = image;
          _profileImageUrl = imageUrl;  
        });
        await _profileController.saveProfileImageUrl(imageUrl); 
      }
    }
  }

 
  Future<void> _pickImageFromCamera() async {
    final image = await _profileController.pickImageFromCamera();
    if (image != null) {
      final imageUrl = await _profileController.uploadProfileImage(image);
      if (imageUrl != null) {
        setState(() {
          _profileImage = image;
          _profileImageUrl = imageUrl;  
        });
        await _profileController.saveProfileImageUrl(imageUrl); 
      }
    }
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar correo electrónico'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Nuevo correo electrónico'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                final newEmail = emailController.text.trim();
                final password = passwordController.text.trim();

                if (user != null && newEmail.isNotEmpty && password.isNotEmpty) {
                  try {
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: password,
                    );
                    await user.reauthenticateWithCredential(credential);

                    await user.verifyBeforeUpdateEmail(newEmail);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Correo de verificación enviado.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar verificación'),
            ),
          ],
        );
      },
    );
  }

 
  void _confirmDeleteAccount() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE0E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Estás a punto de eliminar tu cuenta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text('¿Deseas continuar?', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      final email = user?.email;
                      final password = passwordController.text.trim();

                      if (email != null && password.isNotEmpty) {
                        try {
                          final credential = EmailAuthProvider.credential(
                              email: email, password: password);
                          await user!.reauthenticateWithCredential(credential);
                          await user.delete();

                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continuar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ABAFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nombre = _userData!['nombre'] ?? 'Sin nombre';
    final edad = _userData!['edad']?.toString() ?? 'Desconocida';
    final sexo = _userData!['sexo'] ?? 'Desconocido';
    final viveEnCoatzacoalcos = _userData!['viveEnCoatzacoalcos'] == true;
    final ubicacion = viveEnCoatzacoalcos ? 'Coatzacoalcos' : 'Fuera de alcance';
    final correo = FirebaseAuth.instance.currentUser?.email ?? 'Correo no disponible';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomHeader(title: 'Perfil'),
        
          Container(
            width: 311,
            height: 2,
            color: const Color.fromRGBO(0, 0, 0, 0.20),
            margin: const EdgeInsets.symmetric(vertical: 16),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto de perfil",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset('assets/PhotoBackground.svg', height: 180),
                        CircleAvatar(
                          radius: 90,
                          backgroundImage: _profileImage != null || _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl ?? '')
                              : const AssetImage('assets/images/avatar.png') as ImageProvider,
                          child: _profileImage == null && _profileImageUrl == null
                              ? const Icon(Icons.camera_alt, color: Colors.white, size: 40) 
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _profileImage == null ? _pickImageFromCamera : _pickImage, 
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.lightBlue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                _profileImage == null ? Icons.camera_alt : Icons.edit,  
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Datos que se muestran",
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Nombre: $nombre"),
                  Text("Edad: $edad"),
                  Text("Sexo: $sexo"),
                  Text("Ubicación parcial: $ubicacion"),
                  const SizedBox(height: 24),
                  const Text("Datos de acceso",
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Correo: $correo"),
                  Row(
                    children: [
                      Text(
                        _showPassword
                            ? "Contraseña: ContraseñaSegura123"
                            : "Contraseña: ********",
                      ),
                      IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cerrar sesión"),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Acciones sobre la cuenta",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent)),
                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton(
                      onPressed: _showChangeEmailDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cambiar correo electrónico"),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ABAFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cambiar contraseña"),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (widget.role == 'helper') ...[
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelectSkillsScreen(userData: {}),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Editar habilidades"),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Center(
                    child: ElevatedButton(
                      onPressed: _confirmDeleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Eliminar Cuenta"),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}