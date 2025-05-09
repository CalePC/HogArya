import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../application/controllers/auth_controller.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = AuthController();

  bool isFormFilled = false;
  String error = '';
  Color _buttonColor = const Color(0xFF4ABAFF);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black,
    ));
    emailController.addListener(checkForm);
    passwordController.addListener(checkForm);
  }

  void checkForm() {
    setState(() {
      isFormFilled = emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Transform.translate(
                      offset: const Offset(0, -50.0),
                      child: Image.asset(
                        'assets/LogoHH.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Usuario', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(emailController, false),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contraseña', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(passwordController, true),
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _buttonColor = const Color(0xFF82C5FF)),
                      onTapUp: (_) => setState(() => _buttonColor = const Color(0xFF4ABAFF)),
                      onTapCancel: () => setState(() => _buttonColor = const Color(0xFF4ABAFF)),
                      onTap: isFormFilled
                          ? () => authController.loginUser(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                context: context,
                                onError: (msg) {
                                  setState(() => error = msg);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                },
                              )
                          : null,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isFormFilled ? _buttonColor : const Color(0xFFEDEDED),
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
                    GestureDetector(
                      onTap: () => authController.goToRegister(context),
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

  Widget _buildTextField(TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[800]!),
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
