import 'package:flutter/material.dart';

import '../../../../services/report_service.dart';

import '../../data/report_model.dart';

/**import 'report_detail_page.dart';*/

import 'package:animate_do/animate_do.dart';

import '../../../reports/presentation/pages/report_case_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String searchText = '';

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

  @override
  Widget build(BuildContext context) {
    final ReportService reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Denuncias')),

      body: StreamBuilder<List<ReportModel>>(
        stream: reportService.getReports(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  CircularProgressIndicator(),

                  SizedBox(height: 20),

                  Text('Cargando denuncias...'),
                ],
              ),
            );
          }

          final reports = snapshot.data!;

          final filteredReports = reports.where((report) {
            // SOLO APROBADAS

            if (report.moderationStatus != 'approved') {
              return false;
            }

            final matchesSearch =
                report.title.toLowerCase().contains(searchText.toLowerCase()) ||
                report.description.toLowerCase().contains(
                  searchText.toLowerCase(),
                ); 

            final matchesFilter =
                selectedFilter == 'Todos' || report.category == selectedFilter;

            return matchesSearch && matchesFilter;
          }).toList();

          if (filteredReports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.pets, size: 100, color: Colors.grey),

                  SizedBox(height: 20),

                  Text(
                    'No hay denuncias aún',

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  Text('Sé el primero en reportar'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),

                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar denuncias...',

                    prefixIcon: const Icon(Icons.search),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),

                child: DropdownButtonFormField<String>(
                  initialValue: selectedFilter,

                  items: filters.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },

                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));

                    setState(() {});
                  },

                  child: ListView.builder(
                    itemCount: filteredReports.length,

                    itemBuilder: (context, index) {
                      final report = filteredReports[index];

                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 100)),

                        child: Container(
                          margin: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,

                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,

                                blurRadius: 10,

                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,

                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),

                                  pageBuilder: (_, animation, _) {
                                    return FadeTransition(
                                      opacity: animation,

                                      /** child: ReportDetailPage(report: report), */
                                      child: ReportCasePage(report: report),
                                    );
                                  },
                                ),
                              );
                            },

                            

                            contentPadding: const EdgeInsets.all(15),

                            leading: CircleAvatar(
                              radius: 15,

                              backgroundColor: Colors.red.shade100,

                              child: Hero(
                                tag: report.id,

                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.red,
                                ),
                              ),
                            ),

                            title: Text(
                              report.title,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const SizedBox(height: 8),

                                Text(
                                  report.description,

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Chip(label: Text(report.category)),

                                    const SizedBox(width: 8),

                                    Chip(
                                      label: Text(report.caseStatus),

                                      backgroundColor:
                                          report.caseStatus == 'Pendiente'
                                          ? Colors.orange
                                          : report.caseStatus == 'En proceso'
                                          ? Colors.blue
                                          : Colors.green,
                                    ),
                                  ],
                                ),
                                if (report.response.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),

                                    child: Container(
                                      padding: const EdgeInsets.all(10),

                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,

                                        borderRadius: BorderRadius.circular(10),
                                      ),

                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          const Text(
                                            'Respuesta Entidad',

                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(report.response),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
