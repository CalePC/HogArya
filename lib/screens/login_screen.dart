import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isFormFilled = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(checkForm);
    passwordController.addListener(checkForm);
  }

  void checkForm() {
    setState(() {
      isFormFilled = emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Éxito: Navegar o mostrar mensaje
      print('✅ Usuario autenticado');
      // Navigator.push(...); // navega a tu pantalla principal

    } on FirebaseAuthException catch (e) {
      String message = 'Error desconocido';
      if (e.code == 'user-not-found') {
        message = 'Usuario no registrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        message = 'Correo inválido';
      }

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void goToRegister() {
    print('➡️ Navegar a registro');
    // Navigator.push(...);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🎨 Fondo con degradado solo abajo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.78, 0.95, 1.0],
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFA4DCFF),
                    Color(0xFF4ABAFF),
                  ],
                ),
              ),
            ),
          ),

          // 🧱 Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // 🏠 Logo
                    Transform.translate(
                      offset: const Offset(0, -50.0),
                      child: Image.asset(
                        'assets/LogoHH.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🧑 Usuario
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Usuario',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(emailController, false),

                    const SizedBox(height: 20),

                    // 🔒 Contraseña
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contraseña', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(passwordController, true),

                    const SizedBox(height: 60),

                    // ✅ Botón "Iniciar sesión"
                    GestureDetector(
                      onTap: isFormFilled ? loginUser : null,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isFormFilled
                              ? const Color(0xFF4ABAFF)
                              : const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📝 Botón "Registrarse"
                    GestureDetector(
                      onTap: goToRegister,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔤 Campo reutilizable
  Widget _buildTextField(TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}