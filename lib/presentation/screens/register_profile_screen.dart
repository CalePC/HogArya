import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/register_profile_controller.dart';
import 'package:hogarya/presentation/screens/helper/select_skills_screen.dart';
import 'package:hogarya/presentation/screens/contractor/redirection_driver.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  final controller = RegisterProfileController();
  File? ineImageFile;
  String? ineImageUrl;
  bool isUploading = false;

  Future<void> _pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      ineImageFile = File(picked.path);
      isUploading = true;
    });

    try {
      final ref = FirebaseStorage.instance
      .ref()
      .child('ine/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(ineImageFile!); 
      final url = await ref.getDownloadURL();  

      setState(() {
        ineImageUrl = url;
        isUploading = false;
      });
    } catch (_) {
      setState(() {
        ineImageFile = null;
        ineImageUrl = null;
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen')),
      );
    }
  }

  void _removeImage() {
    setState(() {
      ineImageFile = null;
      ineImageUrl = null;
    });
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _finishRegistration(Map<String, dynamic> args) {
    controller.finishRegistration(
      context: context,
      args: args,
      onError: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      onSuccess: () {
        if (!mounted) return;
        final uid = args['uid'];
        final name = controller.nameController.text.trim();
        final age = int.tryParse(controller.ageController.text.trim()) ?? 0;

        if (controller.selectedRole == 'helper') {
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SelectSkillsScreen(fromRegistro: true)),
          (route) => false,
        );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RedirectionDriver()),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFA4DCFF), Color(0xFF4AB9FF)],
            stops: [0.8, 0.95, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      blendMode: BlendMode.srcIn,
                      child: const Text(
                        'Registro a HouSeHelp',
                        style: TextStyle(
                          fontFamily: 'Instrument Sans',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cuéntanos sobre ti',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _roleButton(
                      label: 'Quiero ser ayudante del hogar',
                      selected: controller.selectedRole == 'helper',
                      onTap: () => setState(() => controller.selectedRole = 'helper'),
                    ),
                    const SizedBox(height: 12),
                    _roleButton(
                      label: 'Necesito ayudante para mi hogar',
                      selected: controller.selectedRole == 'contractor',
                      onTap: () => setState(() => controller.selectedRole = 'contractor'),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Necesitamos saber',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _labelledInput('¿Cuál es tu nombre?', controller.nameController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _labelledInput('Edad', controller.ageController)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedGender,
                            decoration: _inputDecoration('Sexo'),
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                            ],
                            onChanged: (value) =>
                                setState(() => controller.selectedGender = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('¿Radicas o vives en Coatzacoalcos?'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _choiceButton('Sí', controller.livesInCoatzacoalcos == true, () {
                          setState(() => controller.livesInCoatzacoalcos = true);
                        }),
                        const SizedBox(width: 16),
                        _choiceButton('No', controller.livesInCoatzacoalcos == false, () {
                          setState(() => controller.livesInCoatzacoalcos = false);
                        }),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Ayúdanos a verificarte',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text('Sube la parte frontal de tu INE'),
                    const SizedBox(height: 20),
                      if (ineImageFile == null && !isUploading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ineOption(icon: Icons.camera_alt_outlined, label: 'Tomar foto', onTap: () => _pickImage(fromCamera: true)),
                            _ineOption(icon: Icons.image_outlined, label: 'Desde galería', onTap: () => _pickImage(fromCamera: false)),
                          ],
                      )
                      else if (isUploading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(ineImageFile!, width: 200, height: 130, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text("Eliminar"),
                            ),
                          ],
                        ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width / 2 - 66.5,
                child: GestureDetector(
                  onTap: () {
                    if (controller.isFormComplete()) {
                      _finishRegistration(args);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 133,
                    height: 54,
                    decoration: BoxDecoration(
                      color: controller.isFormComplete()
                          ? const Color(0xFF4AB9FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Instrument Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _ineOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  
  Widget _roleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD1ECFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _labelledInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _choiceButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            color: selected ? Colors.black12 : Colors.transparent,
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
