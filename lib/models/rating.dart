class Rating {
  final int? ratingId;
  final int userId;
  final int subserviceId;
  final int score;
  final String? comment;
  final String? timestamp;

  Rating({
    this.ratingId,
    required this.userId,
    required this.subserviceId,
    required this.score,
    this.comment,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating_id': ratingId,
      'user_id': userId,
      'subservice_id': subserviceId,
      'score': score,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      ratingId: map['rating_id'],
      userId: map['user_id'],
      subserviceId: map['subservice_id'],
      score: map['score'],
      comment: map['comment'],
      timestamp: map['timestamp'],
    );
  }
}
