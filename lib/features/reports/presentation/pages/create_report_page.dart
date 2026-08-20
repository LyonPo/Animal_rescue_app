import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/report_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../services/location_service.dart';

import '../../../../services/ai_moderation_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  //variables
  String selectedCategory = 'Maltrato';

  final List<String> categories = [
    'Maltrato',

    'Abandono',

    'Animal Herido',

    'Adopción',

    'Rescate',

    'Extraviado',
  ];

  String getAssignedEntity() {
    if (selectedCategory == 'Maltrato' || selectedCategory == 'Animal Herido') {
      return 'POFOMA';
    }

    if (selectedCategory == 'Abandono' || selectedCategory == 'Extraviado') {
      return 'GAMEA';
    }

    if (selectedCategory == 'Rescate' || selectedCategory == 'Adopción') {
      return 'FUNDACION';
    }

    return 'POFOMA';
  }

  //controllers

  final LocationService locationService = LocationService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final ReportService reportService = ReportService();

  File? image;

  //metodos

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;

    LocationPermission permission;

    // GPS ACTIVADO
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      return;
    }

    // PERMISOS
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();

      return;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> createReport() async {
    final fullText =
        '${titleController.text} '
        '${descriptionController.text}';

    final isSpam = AiModerationService.isSpam(fullText);

    if (isSpam) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contenido detectado como spam o inapropiado'),

          backgroundColor: Colors.red,
        ),
      );

      return;
    } // VALIDAR CAMPOS

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory.isEmpty ||
        image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa todos los campos y agrega una foto'),

          backgroundColor: Colors.red,

          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );

      return;
    }

    // OBTENER UBICACIÓN

    Position? position = await locationService.getCurrentLocation();

    // CREAR DENUNCIA

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userData = userDoc.data();

    await reportService.createReport(
      data: {
        'title': titleController.text.trim(),

        'description': descriptionController.text.trim(),

        'category': selectedCategory,

        "assignedEntity": "PRUEBA",

        'latitude': position?.latitude ?? 0.0,

        'longitude': position?.longitude ?? 0.0,

        'imageUrl': '',

        'userId': uid, // UID del usuario

        'userName': userData?['username'] ?? '',

        'userPhone': userData?['phoneNumber'] ?? '',

        'moderationStatus': 'pending',

        'moderationReason': '',

        'moderatedBy': '',

        'moderatedAt': null,

        'status': 'Pendiente',

        'response': '',
      },
    );

    // MENSAJE ÉXITO

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Denuncia creada correctamente'),

        backgroundColor: Colors.green,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

    // LIMPIAR FORMULARIO

    titleController.clear();

    descriptionController.clear();

    setState(() {
      selectedCategory = 'Maltrato';

      image = null;
    });
  }

  @override
  void initState() {
    super.initState();

    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Denuncia')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                ),
              ),

              child: const Row(
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 40),

                  SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Nueva Denuncia',

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 24,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Ayuda a proteger animales reportando casos.',

                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CATEGORIA
            DropdownButtonFormField<String>(
              value: selectedCategory,

              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: InputDecoration(
                labelText: 'Categoría',

                prefixIcon: const Icon(Icons.category),

                filled: true,

                fillColor: Theme.of(context).cardColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TITULO
            TextField(
              controller: titleController,

              decoration: InputDecoration(
                labelText: 'Título',

                prefixIcon: const Icon(Icons.title),

                filled: true,

                fillColor: Theme.of(context).cardColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPCION
            TextField(
              controller: descriptionController,

              maxLines: 5,

              decoration: InputDecoration(
                labelText: 'Descripción',

                alignLabelWithHint: true,

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),

                  child: Icon(Icons.description),
                ),

                filled: true,

                fillColor: Theme.of(context).cardColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // IMAGEN
            if (image != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Image.file(
                    image!,

                    height: 220,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // BOTON FOTO
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: pickImage,

                icon: const Icon(Icons.camera_alt),

                label: const Text('Tomar Foto'),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // BOTON ENVIAR
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: createReport,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),

                  backgroundColor: Colors.deepPurple,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                child: const Text(
                  'Enviar Denuncia',

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
