class ReviewModel {
  String? id; // Add this for `_id`
  String? productId;
  String? userId;
  int? rating;
  String? comment;
  DateTime? createdOn;
  DateTime? updatedOn;

  ReviewModel({
    this.id, // Include `_id` here
    this.productId,
    this.userId,
    this.rating,
    this.comment,
    this.createdOn,
    this.updatedOn,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['_id'], // Map `_id`
      productId: map['productId'],
      userId: map['userId'],
      rating: map['rating'],
      comment: map['comment'],
      createdOn: map['createdOn'] != null ? DateTime.parse(map['createdOn']) : null,
      updatedOn: map['updatedOn'] != null ? DateTime.parse(map['updatedOn']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdOn': createdOn?.toIso8601String(),
      'updatedOn': updatedOn?.toIso8601String(),
    };
  }
}
