import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': role,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        // Add default fields if it's an elder
        if (role == 'elder') ...{
          'age': '',
          'weight': '',
          'height': '',
          'bloodType': '',
          'caretakerName': '',
          'caretakerRelation': '',
          'allergies': '',
        },
      });

      // Save session manually
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', result.user!.uid);
      await prefs.setString('userRole', role);

      return result;
    } catch (e) {
      throw e;
    }
  }

  // Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch role and save session manually
      String? role = await getUserRole(result.user!.uid);
      if (role != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', result.user!.uid);
        await prefs.setString('userRole', role);
      }

      return result;
    } catch (e) {
      throw e;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get User Role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
