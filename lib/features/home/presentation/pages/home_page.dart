import 'package:flutter/material.dart';

import '../../../maps/presentation/pages/map_page.dart';

import '../../../reports/presentation/pages/reports_page.dart';

import '../../../profile/presentation/pages/profile_page.dart';

/*--import '../../../reports/presentation/pages/create_report_page.dart';--*/

import 'package:animate_do/animate_do.dart';

import '../../../reports/presentation/pages/advanced_create_report_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const MapPage(),

    const ReportsPage(),

    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      floatingActionButton: BounceInUp(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,

              /*--MaterialPageRoute(builder: (_) => const CreateReportPage()),--*/
              MaterialPageRoute(
                builder: (_) => const AdvancedCreateReportPage(),
              ),
            );
          },

          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),

          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Denuncias'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
