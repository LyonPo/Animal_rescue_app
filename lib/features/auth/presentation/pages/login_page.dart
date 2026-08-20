import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';
import 'register_page.dart';

/*--import '../../../maps/presentation/pages/map_page.dart';--*/
import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

void login() async {

  final fakeEmail =
      '${emailController.text.trim()}@huellitas.app';

  final user = await authService.login(

    email: fakeEmail,

    password:
        passwordController.text.trim(),
  );

  if (user != null) {

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            /*--const Icon(Icons.pets, size: 100, color: Colors.green),--*/

            Image.asset('assets/logo.png', height: 120),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: login,
                child: const Text('Iniciar Sesión'),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },

              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
