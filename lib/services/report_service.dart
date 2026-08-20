import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/reports/data/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReport({required Map<String, dynamic> data}) async {
    await _firestore.collection('reports').add(data);
  }

  Stream<List<ReportModel>> getReports() {
    return _firestore.collection('reports').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateStatus(String reportId, String status) async {
    await _firestore.collection('reports').doc(reportId).update({
      'caseStatus': status,
    });
  }

  Future<void> updateResponse(String reportId, String response) async {
    await _firestore.collection('reports').doc(reportId).update({
      'response': response,
    });
  }

  Future<void> moderateReport({
    required String reportId,

    required String status,

    required String reason,

    required String admin,
  }) async {
    await _firestore.collection('reports').doc(reportId).update({
      'moderationStatus': status,

      'moderationReason': reason,

      'moderatedBy': admin,

      'moderatedAt': DateTime.now(),
    });
  }

  Future<void> updateCaseStatus(String reportId, String status) async {
    await _firestore.collection('reports').doc(reportId).update({
      'caseStatus': status,
    });
  }
}
