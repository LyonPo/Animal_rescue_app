import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/report_service.dart';

import '../../../reports/data/report_model.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Función global para abrir WhatsApp
Future<void> openWhatsApp(String phoneNumber, String message) async {
  final Uri url = Uri.parse(
    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
  );

  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Error WhatsApp: $e');
  }
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Estadísticas rápidas
            Row(
              children: [
                Expanded(
                  child: adminCard('Usuarios', Icons.people, Colors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminCard('Entidades', Icons.business, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: adminCard('Denuncias', Icons.warning, Colors.orange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: adminCard(
                    'Admins',
                    Icons.admin_panel_settings,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Gestión usuarios
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gestión Usuarios',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['username'][0].toUpperCase()),
                        ),
                        title: Text(user['username']),
                        subtitle: Text('Rol: ${user['role']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
                                .update({'role': value});
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'user',
                              child: Text('Usuario'),
                            ),
                            const PopupMenuItem(
                              value: 'entity',
                              child: Text('Entidad'),
                            ),
                            const PopupMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),

            // Gestión denuncias
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gestión Denuncias',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<ReportModel>>(
              stream: reportService.getReports(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final reports = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(report.description),
                            const SizedBox(height: 5),
                            Text('Categoría: ${report.category}'),
                            Text('Usuario: ${report.userName}'),
                            Text('Teléfono: ${report.userPhone}'),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    if (report.userPhone.isNotEmpty) {
                                      openWhatsApp(
                                        report.userPhone,
                                        'Hola, nos contactamos desde Huellitas sobre tu denuncia: ${report.title}',
                                      );
                                    }
                                  },
                                ),

                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'approved') {
                                      await FirebaseFirestore.instance
                                          .collection('reports')
                                          .doc(report.id)
                                          .update({'moderationStatus': 'approved',});

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Denuncia aprobada'),
                                        ),
                                      );
                                    } else if (value == 'rejected') {
                                      await FirebaseFirestore.instance
                                          .collection('reports')
                                          .doc(report.id)
                                          .update({'moderationStatus': 'rejected',});

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Denuncia rechazada'),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      await FirebaseFirestore.instance
                                          .collection('reports')
                                          .doc(report.id)
                                          .delete();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Denuncia eliminada'),
                                        ),
                                      );
                                    }
                                  },

                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'approved',

                                      child: Text('Aprobar'),
                                    ),

                                    const PopupMenuItem(
                                      value: 'rejected',

                                      child: Text('Rechazar'),
                                    ),

                                    const PopupMenuItem(
                                      value: 'delete',

                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget adminCard(String title, IconData icon, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
