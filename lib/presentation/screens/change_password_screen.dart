import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hogarya/application/controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final controller = ChangePasswordController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required TextEditingController controllerField,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.black, Color(0xFF4A66FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: "Instrument Sans",
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          width: 357,
          child: TextFormField(
            controller: controllerField,
            obscureText: !obscure,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.black),
                onPressed: onToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFA4DCFF), Color(0xFF4ABAFF)],
              stops: [0.869, 0.9345, 1.0],
            ),
          ),
          child: Column(
            children: [
             
              Container(
                height: 66 + MediaQuery.of(context).padding.top,
                width: double.infinity,
                color: Colors.black,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16,
                ),
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: 'Hog',
                        style: TextStyle(color: Color(0xFF2D409B)),
                      ),
                      TextSpan(
                        text: 'Arya',
                        style: TextStyle(color: Color(0xFF38A5D3)),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF4ABAFF), Color(0xFF4A66FF)],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Instrument Sans",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: SizedBox(
                  width: 311,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    children: [
                      _passwordField(
                        controllerField: controller.oldPassword,
                        label: "Ingrese su antigua contraseña",
                        obscure: _showOld,
                        onToggle: () => setState(() => _showOld = !_showOld),
                        validator: controller.validateOldPassword,
                      ),
                      const SizedBox(height: 24),
                      _passwordField(
                        controllerField: controller.newPassword,
                        label: "Ingrese su nueva contraseña",
                        obscure: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        validator: controller.validateNewPassword,
                      ),
                      const SizedBox(height: 24),
                      _passwordField(
                        controllerField: controller.confirmPassword,
                        label: "Confirme su nueva contraseña",
                        obscure: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        validator: controller.validateConfirmPassword,
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: SizedBox(
                          width: 238,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: controller.isLoading
                                ? null
                                : () => controller.changePassword(
                                      context: context,
                                      onStartLoading: () =>
                                          setState(() => controller.isLoading = true),
                                      onEndLoading: () =>
                                          setState(() => controller.isLoading = false),
                                      onSuccess: () => Navigator.pop(context),
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (controller.formKey.currentState?.validate() ??
                                      false)
                                  ? const Color(0xFF7BD8FF)
                                  : Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: controller.isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    "Cambiar contraseña",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Instrument Sans",
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}