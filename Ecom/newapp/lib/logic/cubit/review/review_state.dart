import 'package:newapp/data/models/review/review_model.dart';

abstract class ReviewState {
  const ReviewState();
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final List<ReviewModel> reviews;

  // Removed the 'averageRating' parameter
  const ReviewSuccess({required this.reviews});
}

class ReviewFailure extends ReviewState {
  final String message;

  const ReviewFailure({required this.message});
}

class ReviewAddedSuccess extends ReviewState {
  final ReviewModel review;

  const ReviewAddedSuccess({required this.review});
}

class ReviewUpdatedSuccess extends ReviewState {
  final ReviewModel review;

  const ReviewUpdatedSuccess({required this.review});
}

class ReviewDeletedSuccess extends ReviewState {
  const ReviewDeletedSuccess();
}
