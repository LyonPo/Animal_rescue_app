import 'package:flutter/material.dart';

import '../../data/report_model.dart';

import '../../../../services/response_service.dart';

import '../../data/response_model.dart';

class ReportCasePage extends StatelessWidget {
  final ReportModel report;

  final ResponseService responseService = ResponseService();

  ReportCasePage({super.key, required this.report});

  Color getUrgencyColor() {
    switch (report.urgency) {
      case 'Emergencia':
        return Colors.red;

      case 'Alta':
        return Colors.orange;

      case 'Media':
        return Colors.amber;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expediente')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: getUrgencyColor(),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,

                    child: Icon(Icons.pets, size: 30),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          report.title,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          report.category,

                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ESTADO
            Row(
              children: [
                Expanded(
                  child: statusCard(
                    'Urgencia',
                    report.urgency,
                    Icons.warning,
                    getUrgencyColor(),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: statusCard(
                    'Caso',
                    report.caseStatus,
                    Icons.gavel,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // DESCRIPCIÓN
            sectionTitle('Descripción'),

            cardContainer(child: Text(report.description)),

            const SizedBox(height: 20),

            // ANIMAL
            sectionTitle('Información Animal'),

            cardContainer(
              child: Column(
                children: [
                  infoRow('Especie', report.species),

                  infoRow('Raza', report.breed),

                  infoRow('Cantidad', report.quantity.toString()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // INFACCIONES
            sectionTitle('Infracciones'),

            Wrap(
              spacing: 10,

              children: report.infractions.map((e) {
                return Chip(label: Text(e));
              }).toList(),
            ),

            const SizedBox(height: 20),

            // REPORTANTE
            sectionTitle('Reportante'),

            cardContainer(
              child: Column(
                children: [
                  infoRow('Usuario', report.userName),

                  infoRow('Entidad asignada', report.assignedEntity),

                  infoRow('Teléfono', report.userPhone),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TIMELINE
            sectionTitle('Seguimiento'),

            timelineItem(
              'Denuncia registrada',
              Icons.check_circle,
              Colors.green,
            ),

            timelineItem(
              'En revisión administrativa',
              Icons.admin_panel_settings,
              Colors.orange,
            ),

            timelineItem(report.caseStatus, Icons.gavel, Colors.blue),

            sectionTitle('Respuestas Entidades'),

            StreamBuilder<List<ResponseModel>>(
              stream: responseService.getResponses(report.id),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final responses = snapshot.data!;

                if (responses.isEmpty) {
                  return const Text(
                    'Aún no existen respuestas institucionales.',
                  );
                }

                return Column(
                  children: responses.map((response) {
                    return Container(
                      width: double.infinity,

                      margin: const EdgeInsets.only(bottom: 10),

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            response.entityName,

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(response.message),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // BOTONES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(Icons.map),

                    label: const Text('Ver Mapa'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    icon: const Icon(Icons.share),

                    label: const Text('Compartir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Text(
        title,

        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),

      child: child,
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          Text(value),
        ],
      ),
    );
  }

  Widget statusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(height: 10),

          Text(title, style: const TextStyle(color: Colors.white)),

          const SizedBox(height: 5),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget timelineItem(String text, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,

              child: Icon(icon, size: 18, color: Colors.white),
            ),

            Container(width: 2, height: 50, color: Colors.grey.shade300),
          ],
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),

            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
