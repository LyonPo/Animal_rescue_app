import 'package:flutter/material.dart';

import '../../data/report_model.dart';

class ReportDetailPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Denuncia')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              height: 220,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.grey.shade300,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Hero(
                tag: report.id,

                child: const Icon(Icons.pets, size: 100, color: Colors.red),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              report.title,

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Chip(label: Text(report.category)),

            const SizedBox(height: 20),

            const Text(
              'Descripción',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(report.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.green.shade50,

                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text('Latitud: ${report.latitude}'),

                  Text('Longitud: ${report.longitude}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
