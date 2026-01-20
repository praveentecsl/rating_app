import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String? id;
  final String userId;
  final int serviceId;
  final int subserviceId;
  final int score;
  final DateTime timestamp;

  Rating({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.subserviceId,
    required this.score,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'subserviceId': subserviceId,
      'score': score,
      'timestamp': timestamp,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      userId: map['userId'],
      serviceId: map['serviceId'],
      subserviceId: map['subserviceId'],
      score: map['score'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
