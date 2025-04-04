import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_account_screen.dart';
import 'register_profile_screen.dart';
import 'package:flutter/services.dart';
import 'contractor/contractor_screen.dart';
import 'helper/helpers_screen.dart';
import 'super/super_user_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isFormFilled = false;
  String error = '';
  Color _buttonColor = const Color(0xFF4ABAFF);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
       statusBarColor: Colors.black,));
    emailController.addListener(checkForm);
    passwordController.addListener(checkForm);
  }

  void checkForm() {
    setState(() {
      isFormFilled = emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  Future<void> loginUser() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      final role = doc['rol'];

      if (context.mounted) {
        if (role == 'helper') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HelpersScreen()),
          );
        } else if (role == 'contractor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ContractorScreen()),
          );
        } else if (role == 'super') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuperUserScreen()),
        );
        } else {
          setState(() => error = 'Rol desconocido.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error al iniciar sesión');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterAccountScreen()),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterProfileScreen(),
            settings: RouteSettings(arguments: result),
          ),
        );
      }
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Contraseña', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(passwordController, true),
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTapDown: (_) {
                        // Color de botón al persionar
                        setState(() {
                          _buttonColor = const Color(0xFF82C5FF);
                        });
                      },
                      onTapUp: (_) {
                       
                        setState(() {
                          _buttonColor = const Color(0xFF4ABAFF);
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _buttonColor = const Color(0xFF4ABAFF);
                        });
                      },
                      onTap: isFormFilled ? loginUser : null,
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isFormFilled
                              ? _buttonColor
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
