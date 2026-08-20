class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String assignedEntity;
  final String status;
  final String response;
  final String moderationStatus;
  final String moderationReason;
  final String moderatedBy;
  final String userPhone;
  final String userId;
  final String userName;

  final String species;
  final String breed;
  final int quantity;
  final String urgency;
  final List<String> infractions;
  final List<String> imageUrls;
  final String caseStatus;

  final double latitude;
  final double longitude;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.assignedEntity,
    required this.status,
    required this.response,
    required this.moderationStatus,
    required this.moderationReason,
    required this.moderatedBy,
    required this.userPhone,
    required this.userId,
    required this.userName,

    required this.species,
    required this.breed,
    required this.quantity,
    required this.urgency,
    required this.infractions,
    required this.imageUrls,
    required this.caseStatus,

    required this.latitude,
    required this.longitude,
  });

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,

      title: map['title'] ?? '',

      description: map['description'] ?? '',

      category: map['category'] ?? '',

      assignedEntity: map['assignedEntity'] ?? '',

      status: map['status'] ?? 'Pendiente',

      response: map['response'] ?? '',

      moderationStatus: map['moderationStatus'] ?? 'pending',

      moderationReason: map['moderationReason'] ?? '',

      moderatedBy: map['moderatedBy'] ?? '',

      userPhone: map['userPhone'] ?? '',

      userName: map['userName'] ?? '',

      userId: map['userId'] ?? '',
    

      species: map['species'] ?? '',

      breed: map['breed'] ?? '',

      quantity: map['quantity'] ?? 0,

      urgency: map['urgency'] ?? '',

      infractions: List<String>.from(
        map['infractions'] ?? [],
      ),

      imageUrls: List<String>.from(
        map['imageUrls'] ?? [],
      ),

      caseStatus:
          map['caseStatus'] ?? 'Pendiente',


      latitude: (map['latitude'] ?? 0.0).toDouble(),

      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }
}
