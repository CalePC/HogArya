import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  String error = '';

  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password != confirm) {
      setState(() => error = 'Las contraseñas no coinciden');
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null && context.mounted) {
        Navigator.pop(context, {
          'uid': user.uid,
          'email': email,
          'password': password,
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error al registrar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.78, 0.95, 1.0],
            colors: [Colors.white, Color(0xFFA4DCFF), Color(0xFF4AB9FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: 30, left: 0, right: 0, height: 22, child: Container(color: Colors.black)),
            const Positioned(
              top: 71,
              left: 16,
              child: Text(
                'Registro a HouSeHelp',
                style: TextStyle(
                  color: Color(0xFF4AB9FF),
                  fontSize: 32,
                  fontFamily: 'Instrument Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              top: 143,
              left: 0,
              right: 0,
              child: Divider(color: Color(0xFF4AB9FF), thickness: 3),
            ),
            Positioned(
              top: 160,
              left: 16,
              right: 16,
              bottom: 100,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Creemos  tu cuenta',
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
                    _buildInputField(controller: emailController),

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
                    _buildInputField(controller: passwordController, obscureText: true),

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
                    _buildInputField(controller: confirmController, obscureText: true),

                    const SizedBox(height: 20),
                    if (error.isNotEmpty)
                      Text(error, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: MediaQuery.of(context).size.width / 2 - 66.5,
              child: GestureDetector(
                onTap: register,
                child: Container(
                  width: 133,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
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
