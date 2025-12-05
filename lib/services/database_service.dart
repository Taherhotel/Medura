import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'users';

  // Fetch user profile
  Stream<DocumentSnapshot> getUserProfile(String userId) {
    return _firestore.collection(collectionPath).doc(userId).snapshots();
  }

  // Create or Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(userId).set(
      data,
      SetOptions(merge: true),
    );
  }
}
