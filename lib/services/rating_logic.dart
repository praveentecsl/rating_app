import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a rating for a service with multiple criteria
  Future<void> submitServiceRating({
    required String userId,
    required int serviceId,
    required Map<String, double> criteriaRatings,
    String? comment,
  }) async {
    // Calculate the average rating for the criteria
    double averageRating = 0;
    if (criteriaRatings.isNotEmpty) {
      averageRating =
          criteriaRatings.values.reduce((a, b) => a + b) /
          criteriaRatings.length;
    }

    await _firestore.collection('serviceRatings').add({
      'userId': userId,
      'serviceId': serviceId,
      'criteriaRatings': criteriaRatings,
      'averageRating':
          averageRating, // Storing the calculated average for easier querying
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
        return {'averageRating': 0.0, 'percentage': 0.0, 'totalRatings': 0};
      }

      double totalOfAverages = 0;
      for (var doc in snapshot.docs) {
        totalOfAverages += (doc.data()['averageRating'] ?? 0);
      }

      double finalAverage = totalOfAverages / snapshot.docs.length;
      double percentage =
          (finalAverage / 10.0) * 100; // Convert 10-star to percentage

      return {
        'averageRating': finalAverage,
        'percentage': percentage,
        'totalRatings': snapshot.docs.length,
      };
    } catch (e) {
      print('Error getting service rating stats: $e');
      return {'averageRating': 0.0, 'percentage': 0.0, 'totalRatings': 0};
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
              'criteriaRatings': data['criteriaRatings'] ?? {},
              'averageRating': data['averageRating'] ?? 0.0,
              'comment': data['comment'],
              'timestamp': data['timestamp'],
            };
          }).toList();
        });
  }

  // Get trending services (sorted by average rating)
  Future<List<Map<String, dynamic>>> getTrendingServices(
    List<int> serviceIds,
  ) async {
    List<Map<String, dynamic>> servicesWithRatings = [];

    for (int serviceId in serviceIds) {
      final stats = await getServiceRatingStats(serviceId);
      servicesWithRatings.add({
        'serviceId': serviceId,
        'averageRating': stats['averageRating'],
        'percentage': stats['percentage'],
        'totalRatings': stats['totalRatings'],
      });
    }

    // Sort by average rating (highest first)
    servicesWithRatings.sort(
      (a, b) => (b['averageRating'] as double).compareTo(
        a['averageRating'] as double,
      ),
    );

    return servicesWithRatings;
  }
}
