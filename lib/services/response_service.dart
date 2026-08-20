import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/reports/data/response_model.dart';

class ResponseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // CREAR RESPUESTA
  Future<void> createResponse({
    required String reportId,
    required String entityName,
    required String message,
  }) async {

    await _firestore
        .collection('responses')
        .add({

      'reportId': reportId,

      'entityName': entityName,

      'message': message,

      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  // OBTENER RESPUESTAS
  Stream<List<ResponseModel>>
      getResponses(String reportId) {

    print('BUSCANDO RESPUESTAS PARA: $reportId');

    return _firestore
        .collection('responses')

        .where(
          'reportId',
          isEqualTo: reportId,
        )

        .orderBy('createdAt')

        .snapshots()

        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return ResponseModel.fromMap(
          doc.id,
          doc.data(),
        );

      }).toList();
    });
  }
}