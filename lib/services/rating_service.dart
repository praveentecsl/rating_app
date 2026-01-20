import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a rating for a service
  Future<void> submitServiceRating({
    required String userId,
    required int serviceId,
    required double rating,
    String? comment,
  }) async {
    await _firestore.collection('serviceRatings').add({
      'userId': userId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get average rating for a service
  Future<Map<String, dynamic>> getServiceRatingStats(int serviceId) async {
    try {
      final snapshot = await _firestore
          .collection('serviceRatings')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'percentage': 0.0,
          'totalRatings': 0,
        };
      }

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0);
      }

      double average = total / snapshot.docs.length;
      double percentage = (average / 5.0) * 100; // Convert 5-star to percentage

      return {
        'averageRating': average,
        'percentage': percentage,
        'totalRatings': snapshot.docs.length,
      };
    } catch (e) {
      return {
        'averageRating': 0.0,
        'percentage': 0.0,
        'totalRatings': 0,
      };
    }
  }

  // Get all ratings for a service with stats
  Stream<List<Map<String, dynamic>>> getServiceRatings(int serviceId) {
    return _firestore
        .collection('serviceRatings')
        .where('serviceId', isEqualTo: serviceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'] ?? '',
          'rating': data['rating'] ?? 0.0,
          'comment': data['comment'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }

  // Get trending services (sorted by average rating)
  Future<List<Map<String, dynamic>>> getTrendingServices(
      List<int> serviceIds) async {
    List<Map<String, dynamic>> servicesWithRatings = [];

    for (int serviceId in serviceIds) {
      final stats = await getServiceRatingStats(serviceId);
      servicesWithRatings.add({
        'serviceId': serviceId,
        'averageRating': stats['averageRating'],
        'ratingCount': stats['totalRatings'],
      });
    }

    // Sort by average rating (highest first)
    servicesWithRatings.sort(
        (a, b) => (b['averageRating'] as num).compareTo(a['averageRating'] as num));

    return servicesWithRatings;
  }

  // Submit a rating for a sub-service
  Future<void> submitRating(Rating rating) async {
    await _firestore.collection('ratings').add(rating.toMap());
  }

  // Get user's rating statistics for a specific service
  Future<Map<String, dynamic>> getUserServiceRating(
      String userId, int serviceId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .where('serviceId', isEqualTo: serviceId)
        .get();

    if (snapshot.docs.isEmpty) {
      return {'ratings_given': 0, 'user_average': 0.0};
    }

    double totalScore = 0;
    for (var doc in snapshot.docs) {
      totalScore += doc.data()['score'] ?? 0;
    }

    return {
      'ratings_given': snapshot.docs.length,
      'user_average': totalScore / snapshot.docs.length,
    };
  }

  // Check if user has already rated a service
  Future<bool> hasUserRated(String userId, int serviceId) async {
    final snapshot = await _firestore
        .collection('serviceRatings')
        .where('userId', isEqualTo: userId)
        .where('serviceId', isEqualTo: serviceId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get user's rating for a service
  Future<double?> getUserRating(String userId, int serviceId) async {
    final snapshot = await _firestore
        .collection('serviceRatings')
        .where('userId', isEqualTo: userId)
        .where('serviceId', isEqualTo: serviceId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    return snapshot.docs.first.data()['rating'];
  }
}
