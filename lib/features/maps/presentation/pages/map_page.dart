import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

import '../../../../services/report_service.dart';

import '../../../reports/data/report_model.dart';

import '../../../reports/presentation/pages/report_case_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String selectedFilter = 'Todos';

  final List<String> filters = [
    'Todos',
    'Maltrato',
    'Abandono',
    'Animal Herido',
    'Adopción',
    'Rescate',
    'Extraviado',
  ];

  Color getMarkerColor(String urgency) {
    switch (urgency) {
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
    final ReportService reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Denuncias')),

      body: StreamBuilder<List<ReportModel>>(
        stream: reportService.getReports(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!
              .where((report) => report.latitude != 0 && report.longitude != 0 && report.moderationStatus == 'approved')
              .toList();
          

          final filteredReports = reports.where((report) {
            if (selectedFilter == 'Todos') {
              return true;
            }
        

            return report.category == selectedFilter;
          }).toList();

          print('TOTAL REPORTS: ${reports.length}');

          return Column(
            children: [
              SizedBox(
                height: 60,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: filters.length,

                  itemBuilder: (context, index) {
                    final filter = filters[index];

                    final isSelected = selectedFilter == filter;

                    return Padding(
                      padding: const EdgeInsets.all(8),

                      child: ChoiceChip(
                        label: Text(filter),

                        selected: isSelected,

                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: reports.isNotEmpty
                        ? LatLng(
                            reports.first.latitude,
                            reports.first.longitude,
                          )
                        : const LatLng(-16.5000, -68.15000),

                    initialZoom: 15,
                  ),

                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',

                      userAgentPackageName: 'com.example.animal_rescue_app',
                    ),

                    MarkerLayer(
                      markers: filteredReports.map((report) {
                        return Marker(
                          point: LatLng(report.latitude, report.longitude),

                          width: 90,
                          height: 90,

                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,

                                backgroundColor: Colors.transparent,

                                builder: (_) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),

                                    decoration: const BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25),
                                      ),
                                    ),

                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,

                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: getMarkerColor(
                                                report.urgency,
                                              ),

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
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        Chip(label: Text(report.category)),

                                        const SizedBox(height: 10),

                                        Text(report.description),

                                        const SizedBox(height: 15),

                                        Text('Usuario: ${report.userName}'),

                                        const SizedBox(height: 5),

                                        Text('Urgencia: ${report.urgency}'),

                                        const SizedBox(height: 5),

                                        Text('Estado: ${report.caseStatus}'),

                                        const SizedBox(height: 20),

                                        SizedBox(
                                          width: double.infinity,

                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,

                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ReportCasePage(
                                                        report: report,
                                                      ),
                                                ),
                                              );
                                            },

                                            icon: const Icon(Icons.visibility),

                                            label: const Text('Ver Expediente'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },

                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_on,

                                  size: 45,

                                  color: getMarkerColor(report.urgency),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.black87,

                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Text(
                                    report.category,

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
