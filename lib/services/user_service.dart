import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/data/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String username,
    required String role,
    required String phoneNumber,
    String entityType = '',
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,

      'role': role,

      'phoneNumber': phoneNumber,

      'verified': false,

      'createdAt': FieldValue.serverTimestamp(),

      'entityType': entityType,
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<UserModel?> getCurrentUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data();
    }

    return null;
  }
}
