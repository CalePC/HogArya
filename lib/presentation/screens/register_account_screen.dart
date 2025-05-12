import 'package:flutter/material.dart';
import 'package:hogarya/application/controllers/register_controller.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final controller = RegisterController();
  String error = '';

  @override
  void initState() {
    super.initState();
    controller.emailController.addListener(_refresh);
    controller.passwordController.addListener(_refresh);
    controller.confirmController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final result = await controller.register(context, (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFA4DCFF),
              Color(0xFF4AB9FF),
            ],
            stops: [0.78, 0.95, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShaderMask(
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
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Creemos tu cuenta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Instrument Sans',
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          '¿Cuál será tu correo?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Instrument Sans',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(controller.emailController),
                        const SizedBox(height: 28),
                        const Text(
                          'Por favor, crea una contraseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Instrument Sans',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(controller.passwordController, obscureText: true),
                        const SizedBox(height: 28),
                        const Text(
                          'Confirma tu contraseña',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Instrument Sans',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(controller.confirmController, obscureText: true),
                        const SizedBox(height: 20),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: controller.isFormComplete() ? _onRegister : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 133,
                    height: 64,
                    decoration: BoxDecoration(
                      color: controller.isFormComplete() ? const Color(0xFF4AB9FF) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Instrument Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFA),
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
