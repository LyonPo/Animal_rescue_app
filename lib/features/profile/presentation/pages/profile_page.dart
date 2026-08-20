import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';

import '../../../auth/presentation/pages/login_page.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/user_service.dart';

import '../../../auth/data/user_model.dart';

import '../../../entity/presentation/pages/entity_dashboard_page.dart';

import '../../../admin/presentation/pages/admin_dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();

  final UserService userService = UserService();

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final user = await userService.getCurrentUser(uid);

    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),

            const SizedBox(height: 20),

            Text(user?.email ?? '', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Text(
              'Rol: ${currentUser?.role ?? ''}',

              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            Text(
              currentUser?.verified == true
                  ? 'Cuenta Verificada'
                  : 'Cuenta No Verificada',

              style: TextStyle(
                color: currentUser?.verified == true
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            if (currentUser?.role == 'entity')
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => EntityDashboardPage(),
                      ),
                    );
                  },

                  icon: const Icon(Icons.verified),

                  label: const Text('Panel Entidad'),

                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),

            const SizedBox(height: 20),

            if (currentUser?.role== 'admin')
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings),

                  label: const Text('Dashboard Admin'),

                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  await authService.logout();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,

                      MaterialPageRoute(builder: (_) => const LoginPage()),

                      (route) => false,
                    );
                  }
                },

                child: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
