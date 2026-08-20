class UserModel {
  final String uid;

  final String username;

  final String role;

  final bool verified;

  final String entityType;

  UserModel({
    required this.uid,

    required this.username,

    required this.role,

    required this.verified,

    required this.entityType,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,

      username: map['username'] ?? '',

      role: map['role'] ?? 'user',

      verified: map['verified'] ?? false,

      entityType: map['entityType'] ?? '',
    );
  }
}
