import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_help/screens/helper/helpers_screen.dart';
import 'contractor/redirection_driver.dart';

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({super.key});

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  String selectedRole = '';
  String selectedGender = 'Masculino';
  bool livesInCoatzacoalcos = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Future<void> finishRegistration(Map<String, dynamic> args) async {
    final uid = args['uid'];
    final email = args['email'];
    final password = args['password'];
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;

    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un rol antes de continuar')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'nombre': name,
      'sexo': selectedGender,
      'rol': selectedRole,
      'edad': age,
      'viveEnCoatzacoalcos': livesInCoatzacoalcos,
      'email': email,
      'password': password,
    });

    if (!mounted) return;

    if (selectedRole == 'helper') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HelpersScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RedirectionDriver()),
        (route) => false,
      );
    }
  }

  bool isFormComplete() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;
    return name.isNotEmpty && age > 0 && selectedRole.isNotEmpty;
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
            colors: [
              Colors.white,
              Color(0xFFA4DCFF),
              Color(0xFF4AB9FF),
            ],
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _roleButton(
                      label: 'Quiero ser ayudante del hogar',
                      selected: selectedRole == 'helper',
                      onTap: () => setState(() => selectedRole = 'helper'),
                    ),
                    const SizedBox(height: 12),
                    _roleButton(
                      label: 'Necesito ayudante para mi hogar',
                      selected: selectedRole == 'contractor',
                      onTap: () => setState(() => selectedRole = 'contractor'),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Necesitamos saber',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _labelledInput('¿Cuál es tu nombre?', nameController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _labelledInput('Edad', ageController)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: _inputDecoration('Sexo'),
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                            ],
                            onChanged: (value) => setState(() => selectedGender = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('¿Radicas o vives en Coatzacoalcos?'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _choiceButton('Sí', livesInCoatzacoalcos == true, () {
                          setState(() => livesInCoatzacoalcos = true);
                        }),
                        const SizedBox(width: 16),
                        _choiceButton('No', livesInCoatzacoalcos == false, () {
                          setState(() => livesInCoatzacoalcos = false);
                        }),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Ayúdanos a verificarte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Sube la parte frontal de tu INE'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt_outlined, size: 40),
                        SizedBox(width: 20),
                        Icon(Icons.image_outlined, size: 40),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Tomar foto'),
                        SizedBox(width: 36),
                        Text('Ir a galería'),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width / 2 - 66.5,
                child: GestureDetector(
                  onTap: () {
                    if (isFormComplete()) {
                      finishRegistration(args);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 133,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isFormComplete() ? const Color(0xFF4AB9FF) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 1),
                    ),
                    child: Center(
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

  Widget _roleButton({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD1ECFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.blueAccent : Colors.transparent, width: 2),
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
          child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        ),
      ),
    );
  }
}
