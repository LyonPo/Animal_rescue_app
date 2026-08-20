import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

/*--import '../../../../services/storage_service.dart';--*/

import '../../../../services/report_service.dart';

import '../../../../services/location_service.dart';

import '../../../../services/user_service.dart';

import 'package:geolocator/geolocator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdvancedCreateReportPage extends StatefulWidget {
  const AdvancedCreateReportPage({super.key});

  @override
  State<AdvancedCreateReportPage> createState() =>
      _AdvancedCreateReportPageState();
}

class _AdvancedCreateReportPageState extends State<AdvancedCreateReportPage> {
  int currentStep = 0;

  // CONTROLADORES
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  final breedController = TextEditingController();

  final quantityController = TextEditingController();

  // VARIABLES
  String selectedCategory = 'Maltrato';

  String selectedSpecies = 'Canino';

  String selectedUrgency = 'Media';

  bool declarationAccepted = false;

  List<File> images = [];

  /*--final StorageService storageService = StorageService();-*/

  final ReportService reportService = ReportService();

  final LocationService locationService = LocationService();

  final UserService userService = UserService();

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

  final List<String> species = ['Canino', 'Felino', 'Equino', 'Otros'];

  final List<String> urgencies = ['Baja', 'Media', 'Alta', 'Emergencia'];

  final List<String> infractions = [
    'Actos de Crueldad',
    'Abandono',
    'Maltrato Físico',
    'Envenenamiento',
    'Peleas de Perros',
    'Otros',
  ];

  List<String> selectedInfractions = [];

  // FOTO
  Future<void> pickImage() async {
    if (images.length >= 5) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
      });
    }
  }

  // ENVIAR
  Future<void> submitReport() async {
    if (!declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar la declaración')),
      );

      return;
    }

    try {
      // USUARIO ACTUAL
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      // DATOS USUARIO
      final userData = await userService.getUserData(currentUser.uid);

      // UBICACIÓN
      Position? position = await locationService.getCurrentLocation();

      // SUBIR IMÁGENES
      List<String> imageUrls = [];

      /*--for (File image in images) {
      final url =
          await storageService.uploadImage(
        image,
      );

      imageUrls.add(url);
    }--*/

      // GUARDAR FIRESTORE
      await reportService.createReport(
        data: {
          'title': titleController.text.trim(),

          'description': descriptionController.text.trim(),

          'category': selectedCategory,

          'assignedEntity': getAssignedEntity(),

          'latitude': position?.latitude ?? 0,

          'longitude': position?.longitude ?? 0,

          'userId': currentUser.uid,

          'userName': userData?['username'] ?? '',

          'userPhone': userData?['phoneNumber'] ?? '',

          'species': selectedSpecies,

          'breed': breedController.text.trim(),

          'quantity': int.tryParse(quantityController.text) ?? 1,

          'urgency': selectedUrgency,

          'infractions': selectedInfractions,

          'imageUrls': imageUrls,

          'moderationStatus': 'pending',

          'caseStatus': 'Pendiente',

          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denuncia enviada correctamente 🚀')),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Denuncia')),

      body: Stepper(
        currentStep: currentStep,

        onStepContinue: () {
          if (currentStep < 4) {
            setState(() {
              currentStep++;
            });
          } else {
            submitReport();
          }
        },

        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },

        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),

            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,

                    child: Text(currentStep == 4 ? 'Enviar' : 'Continuar'),
                  ),
                ),

                const SizedBox(width: 10),

                if (currentStep != 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,

                      child: const Text('Atrás'),
                    ),
                  ),
              ],
            ),
          );
        },

        steps: [
          // PASO 1
          Step(
            title: const Text('Información'),

            isActive: currentStep >= 0,

            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,

                  items: categories.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: selectedUrgency,

                  items: urgencies.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedUrgency = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Urgencia'),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: titleController,

                  decoration: const InputDecoration(labelText: 'Título'),
                ),
              ],
            ),
          ),

          // PASO 2
          Step(
            title: const Text('Animal'),

            isActive: currentStep >= 1,

            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSpecies,

                  items: species.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedSpecies = value!;
                    });
                  },

                  decoration: const InputDecoration(labelText: 'Especie'),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: quantityController,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    labelText: 'Cantidad de animales',
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: breedController,

                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
              ],
            ),
          ),

          // PASO 3
          Step(
            title: const Text('Infracción'),

            isActive: currentStep >= 2,

            content: Column(
              children: infractions.map((e) {
                return CheckboxListTile(
                  value: selectedInfractions.contains(e),

                  title: Text(e),

                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedInfractions.add(e);
                      } else {
                        selectedInfractions.remove(e);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          // PASO 4
          Step(
            title: const Text('Evidencias'),

            isActive: currentStep >= 3,

            content: Column(
              children: [
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: pickImage,

                    icon: const Icon(Icons.camera_alt),

                    label: Text('Subir Evidencia (${images.length}/5)'),
                  ),
                ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,

                  children: images.map((img) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),

                      child: Image.file(
                        img,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // PASO 5
          Step(
            title: const Text('Confirmación'),

            isActive: currentStep >= 4,

            content: Column(
              children: [
                TextField(
                  controller: descriptionController,

                  maxLines: 5,

                  decoration: const InputDecoration(
                    labelText: 'Descripción completa',
                  ),
                ),

                const SizedBox(height: 20),

                CheckboxListTile(
                  value: declarationAccepted,

                  onChanged: (value) {
                    setState(() {
                      declarationAccepted = value!;
                    });
                  },

                  title: const Text(
                    'Declaro que la información proporcionada es verdadera',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
