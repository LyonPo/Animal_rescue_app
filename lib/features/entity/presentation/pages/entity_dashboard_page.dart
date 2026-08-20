import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/report_service.dart';
import '../../../../services/response_service.dart';
import '../../../../services/user_service.dart';
import '../../../../services/notification_service.dart';

import '../../../reports/data/report_model.dart';

import 'municipal_stats_page.dart';

class EntityDashboardPage extends StatefulWidget {
  const EntityDashboardPage({super.key});

  @override
  State<EntityDashboardPage> createState() => _EntityDashboardPageState();
}

class _EntityDashboardPageState extends State<EntityDashboardPage> {
  final UserService userService = UserService();

  final ReportService reportService = ReportService();

  final ResponseService responseService = ResponseService();

  final NotificationService notificationService = NotificationService();

  final TextEditingController responseController = TextEditingController();

  String selectedFilter = 'Todos';

  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  Set<String> _knownReportIds = {};
  bool _initialReportsLoaded = false;

  void listenForNewReports(String entityType) {
    _notificationSubscription?.cancel();

    _notificationSubscription = FirebaseFirestore.instance
        .collection('reports')
        .where('assignedEntity', isEqualTo: entityType)
        .snapshots()
        .listen((snapshot) async {
          final currentIds = snapshot.docs.map((doc) => doc.id).toSet();

          // Primera carga:
          // solamente guardamos las denuncias existentes.
          if (!_initialReportsLoaded) {
            _knownReportIds = currentIds;
            _initialReportsLoaded = true;
            return;
          }

          // Detectar denuncias nuevas.
          final newReports = snapshot.docs.where(
            (doc) => !_knownReportIds.contains(doc.id),
          );

          for (final doc in newReports) {
            final data = doc.data();

            final title = data['title'] ?? 'Nueva denuncia';
            final category = data['category'] ?? 'Sin categoría';

            await notificationService.showNotification(
              title: '🚨 Nueva denuncia',
              body: '$category: $title',
            );
          }

          _knownReportIds = currentIds;
        });
  }

  @override
  void initState() {
    super.initState();

    _initializeEntityNotifications();
  }

  Future<void> _initializeEntityNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final userData = await userService.getUserData(uid);

    if (userData == null) return;

    final entityType = userData['entityType'];

    if (entityType == null) return;

    listenForNewReports(entityType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Entidad'),

        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const MunicipalStatsPage()),
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: userService.getUserData(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = userSnapshot.data!;

          return StreamBuilder<List<ReportModel>>(
            stream: reportService.getReports(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allReports = snapshot.data!;

              final reports = allReports.where((report) {
                return report.assignedEntity == currentUser['entityType'];
              }).toList();

              List<ReportModel> filteredReports = reports;

              if (selectedFilter != 'Todos') {
                filteredReports = reports.where((report) {
                  return report.urgency == selectedFilter;
                }).toList();
              }

              final totalCases = reports.length;

              final inProgress = reports
                  .where((r) => r.caseStatus == 'En proceso')
                  .length;

              final closedCases = reports
                  .where((r) => r.caseStatus == 'Resuelto')
                  .length;

              final urgentCases = reports
                  .where((r) => r.urgency == 'Emergencia')
                  .length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(15),

                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            'Casos',
                            totalCases.toString(),
                            Icons.folder,
                            Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: statCard(
                            'Urgentes',
                            urgentCases.toString(),
                            Icons.warning,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            'Proceso',
                            inProgress.toString(),
                            Icons.gavel,
                            Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: statCard(
                            'Resueltos',
                            closedCases.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedFilter,

                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Todos')),

                        DropdownMenuItem(
                          value: 'Emergencia',
                          child: Text('Emergencia'),
                        ),

                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),

                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                      ],

                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filteredReports.length,

                      itemBuilder: (context, index) {
                        final report = filteredReports[index];

                        const SizedBox(height: 20);

                        // TU CARD ACTUAL

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(15),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.orange,

                                      child: const Icon(
                                        Icons.pets,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        report.title,

                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        await reportService.updateStatus(
                                          report.id,

                                          value,
                                        );
                                      },

                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Pendiente',

                                          child: Text('Pendiente'),
                                        ),

                                        const PopupMenuItem(
                                          value: 'En proceso',

                                          child: Text('En proceso'),
                                        ),

                                        const PopupMenuItem(
                                          value: 'Resuelto',

                                          child: Text('Resuelto'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Text(report.description),

                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 10,

                                  children: [
                                    Chip(label: Text(report.category)),

                                    Chip(
                                      backgroundColor: Colors.orange.shade100,

                                      label: Text(report.urgency),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,

                                            builder: (_) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Responder Caso',
                                                ),

                                                content: TextField(
                                                  controller:
                                                      responseController,

                                                  maxLines: 4,

                                                  decoration: const InputDecoration(
                                                    hintText:
                                                        'Escriba respuesta institucional',
                                                  ),
                                                ),

                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },

                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),

                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      await responseService
                                                          .createResponse(
                                                            reportId: report.id,

                                                            entityName: report
                                                                .assignedEntity,

                                                            message:
                                                                responseController
                                                                    .text,
                                                          );

                                                      responseController
                                                          .clear();

                                                      Navigator.pop(context);
                                                    },

                                                    child: const Text('Enviar'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },

                                        icon: const Icon(Icons.reply),

                                        label: const Text('Responder'),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await reportService.updateCaseStatus(
                                            report.id,
                                            'En proceso',
                                          );
                                        },

                                        icon: const Icon(Icons.gavel),

                                        label: const Text('Tomar Caso'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    responseController.dispose();

    super.dispose();
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 120,

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.white, size: 35),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/*--import 'package:flutter/material.dart';

import '../../../../services/report_service.dart';

import '../../../reports/data/report_model.dart';

import 'municipal_stats_page.dart';

class EntityDashboardPage extends StatelessWidget {
  const EntityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = ReportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Entidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const MunicipalStatsPage()),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<ReportModel>>(
        stream: reportService.getReports(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;

          return ListView.builder(
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final report = reports[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  report.title,

                                  style: const TextStyle(
                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(report.description),

                                const SizedBox(height: 10),

                                Text('Estado: ${report.status}'),
                              ],
                            ),
                          ),

                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              await reportService.updateStatus(
                                report.id,

                                value,
                              );
                            },

                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Pendiente',

                                child: Text('Pendiente'),
                              ),

                              const PopupMenuItem(
                                value: 'En Proceso',

                                child: Text('En Proceso'),
                              ),

                              const PopupMenuItem(
                                value: 'Resuelto',

                                child: Text('Resuelto'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Align(
                        alignment: Alignment.centerRight,

                        child: IconButton(
                          icon: const Icon(Icons.message),

                          onPressed: () {
                            final controller = TextEditingController();

                            showDialog(
                              context: context,

                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('Responder Denuncia'),

                                  content: TextField(
                                    controller: controller,

                                    maxLines: 4,

                                    decoration: const InputDecoration(
                                      hintText: 'Escribe respuesta...',
                                    ),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      child: const Text('Cancelar'),
                                    ),

                                    ElevatedButton(
                                      onPressed: () async {
                                        await reportService.updateResponse(
                                          report.id,

                                          controller.text,
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },

                                      child: const Text('Enviar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),

                      if (report.response.isNotEmpty)
                        Container(
                          width: double.infinity,

                          margin: const EdgeInsets.only(top: 10),

                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Respuesta Entidad',

                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 5),

                              Text(report.response),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}--*/
