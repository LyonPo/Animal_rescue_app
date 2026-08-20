class ResponseModel {
  final String id;

  final String reportId;

  final String entityName;

  final String message;

  ResponseModel({
    required this.id,
    required this.reportId,
    required this.entityName,
    required this.message,
  });

  factory ResponseModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ResponseModel(
      id: id,

      reportId: map['reportId'] ?? '',

      entityName:
          map['entityName'] ?? '',

      message:
          map['message'] ?? '',
    );
  }
}