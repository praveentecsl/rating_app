import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_models;
import '../models/rating.dart';
import '../models/service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ User Operations ============
  
  // Create or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String universityId,
    required String name,
    required String role,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'universityId': universityId,
      'name': name,
      'role': role,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user by UID
  Future<app_models.User?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return app_models.User(
          universityId: data['universityId'] ?? '',
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          password: '', // Don't expose password
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user by university ID
  Future<app_models.User?> getUserByUniversityId(String universityId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('universityId', isEqualTo: universityId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return app_models.User(
          universityId: data['universityId'] ?? '',
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          password: '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============ Service Operations ============

  // Get all services
  Stream<List<Service>> getServices() {
    return _firestore
        .collection('services')
        .orderBy('serviceName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Service(
          serviceId: int.tryParse(doc.id),
          serviceName: data['serviceName'] ?? '',
          description: data['description'],
          imagePath: data['imagePath'],
        );
      }).toList();
    });
  }

  // Add a new service
  Future<String> addService(Service service) async {
    final docRef = await _firestore.collection('services').add({
      'serviceName': service.serviceName,
      'description': service.description,
      'imagePath': service.imagePath,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ============ Rating Operations ============

  // Submit a rating
  Future<void> submitRating({
    required int userId,
    required int subserviceId,
    required int score,
    String? comment,
  }) async {
    await _firestore.collection('ratings').add({
      'userId': userId,
      'subserviceId': subserviceId,
      'score': score,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get ratings for a subservice
  Stream<List<Rating>> getRatingsForSubservice(int subserviceId) {
    return _firestore
        .collection('ratings')
        .where('subserviceId', isEqualTo: subserviceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Rating(
          ratingId: int.tryParse(doc.id),
          userId: data['userId'] ?? 0,
          subserviceId: data['subserviceId'] ?? 0,
          score: data['score'] ?? 0,
          comment: data['comment'],
          timestamp: data['timestamp'],
        );
      }).toList();
    });
  }

  // Get average rating for a subservice
  Future<double> getAverageRating(int subserviceId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('subserviceId', isEqualTo: subserviceId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['score'] ?? 0);
      }

      return total / snapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }
}
