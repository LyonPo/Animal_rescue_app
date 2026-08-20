import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../../../services/report_service.dart';

import '../../../reports/data/report_model.dart';

class MunicipalStatsPage
    extends StatelessWidget {

  const MunicipalStatsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final ReportService reportService =
        ReportService();

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Estadísticas Municipales',
        ),
      ),

      body:
          StreamBuilder<List<ReportModel>>(

        stream:
            reportService.getReports(),

        builder:
            (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          final reports =
              snapshot.data!;

          final total =
              reports.length;

          final pending =
              reports
                  .where(
                    (r) =>
                        r.status ==
                        'Pendiente',
                  )
                  .length;

          final process =
              reports
                  .where(
                    (r) =>
                        r.status ==
                        'En Proceso',
                  )
                  .length;

          final resolved =
              reports
                  .where(
                    (r) =>
                        r.status ==
                        'Resuelto',
                  )
                  .length;

          final maltrato =
              reports
                  .where(
                    (r) =>
                        r.category ==
                        'Maltrato',
                  )
                  .length;

          final abandono =
              reports
                  .where(
                    (r) =>
                        r.category ==
                        'Abandono',
                  )
                  .length;

          final heridos =
              reports
                  .where(
                    (r) =>
                        r.category ==
                        'Animal Herido',
                  )
                  .length;

          return SingleChildScrollView(

            padding:
                const EdgeInsets.all(
                    20),

            child: Column(

              children: [

                Row(

                  children: [

                    Expanded(

                      child: statCard(

                        'Total',

                        total.toString(),

                        Icons.pets,
                      ),
                    ),

                    const SizedBox(
                        width: 10),

                    Expanded(

                      child: statCard(

                        'Resueltos',

                        resolved
                            .toString(),

                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(

                  padding:
                      const EdgeInsets.all(
                          20),

                  decoration: BoxDecoration(

                    color:
                        Theme.of(context)
                            .cardColor,

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Column(

                    children: [

                      const Text(

                        'Estado Denuncias',

                        style: TextStyle(

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      SizedBox(

                        height: 250,

                        child: PieChart(

                          PieChartData(

                            sections: [

                              PieChartSectionData(

                                value: pending
                                    .toDouble(),

                                title:
                                    'Pend.',

                                radius: 60,
                              ),

                              PieChartSectionData(

                                value: process
                                    .toDouble(),

                                title:
                                    'Proceso',

                                radius: 60,
                              ),

                              PieChartSectionData(

                                value: resolved
                                    .toDouble(),

                                title:
                                    'Resuelto',

                                radius: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(

                  padding:
                      const EdgeInsets.all(
                          20),

                  decoration: BoxDecoration(

                    color:
                        Theme.of(context)
                            .cardColor,

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Column(

                    children: [

                      const Text(

                        'Categorías',

                        style: TextStyle(

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      statRow(
                        'Maltrato',
                        maltrato,
                      ),

                      statRow(
                        'Abandono',
                        abandono,
                      ),

                      statRow(
                        'Heridos',
                        heridos,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget statCard(

    String title,

    String value,

    IconData icon,

  ) {

    return Container(

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(
                20),

        color: Colors.deepPurple,
      ),

      child: Column(

        children: [

          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),

          const SizedBox(height: 10),

          Text(

            value,

            style: const TextStyle(

              fontSize: 28,

              fontWeight:
                  FontWeight.bold,

              color: Colors.white,
            ),
          ),

          Text(

            title,

            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget statRow(

    String label,

    int value,

  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(label),

          Text(

            value.toString(),

            style: const TextStyle(

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}