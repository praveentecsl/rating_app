import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;
import '../db/database_helper.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Get current user data from Firestore
  Future<app_models.User?> getCurrentUserData() async {
    print('DEBUG AuthService: Getting current user data');
    final firebaseUser = _firebaseAuth.currentUser;
    print('DEBUG AuthService: Firebase user: ${firebaseUser?.uid}');
    if (firebaseUser == null) return null;
    return await getUserData(firebaseUser.uid);
  }

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String universityId,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'universityId': universityId,
        'name': name,
        'role': role,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Account created successfully'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {'success': true, 'message': 'Login successful'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign in with university ID (we'll use email format: universityId@ruhuna.ac.lk)
  Future<Map<String, dynamic>> signInWithUniversityId({
    required String universityId,
    required String password,
  }) async {
    try {
      // Convert university ID to email format
      String email = '$universityId@ruhuna.ac.lk';

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {'success': true, 'message': 'Login successful'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Get user data from Firestore and sync with local database
  Future<app_models.User?> getUserData(String uid) async {
    try {
      print('DEBUG AuthService: Fetching user from Firestore...');
      final doc = await _firestore.collection('users').doc(uid).get();
      print('DEBUG AuthService: Firestore doc exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data()!;
        final universityId = data['universityId'] ?? '';
        print(
          'DEBUG AuthService: User data from Firestore: name=${data['name']}, universityId=$universityId',
        );

        // Create user object from Firestore data
        final firestoreUser = app_models.User(
          universityId: universityId,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          password: 'firebase_auth', // Placeholder for Firebase users
        );

        print('DEBUG AuthService: Syncing with local database...');
        // Sync with local database and get user with userId
        final dbHelper = DatabaseHelper.instance;
        final localUserId = await dbHelper
            .insertOrUpdateUser(firestoreUser)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                print(
                  'DEBUG AuthService: Database sync timed out, using UID hash as userId',
                );
                return uid.hashCode.abs(); // Use hash of UID as fallback
              },
            );
        print('DEBUG AuthService: Local user ID: $localUserId');

        // Return user with local database ID

        // Return user with UID as userId
        return app_models.User(
          userId: uid,
          universityId: universityId,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
        );
      }
      print('DEBUG AuthService: User document does not exist');
      return null;
    } catch (e, stackTrace) {
      print('DEBUG AuthService: Error getting user data: $e');
      print('DEBUG AuthService: Stack trace: $stackTrace');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this university ID.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid university ID format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'This university ID is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
