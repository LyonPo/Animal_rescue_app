import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  void register() async {
    final fakeEmail = '${emailController.text.trim()}@huellitas.app';

    final user = await authService.register(
      email: fakeEmail,

      password: passwordController.text.trim(),
    );

    if (user != null) {
      await userService.createUser(
        uid: user.uid,

        username: emailController.text.trim(),

        role: 'user',

        phoneNumber: phoneController.text.trim(),
      );
    }

    if (user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuario registrado')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                labelText: 'WhatsApp',

                hintText: '59171234567',
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: register,
                child: const Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
