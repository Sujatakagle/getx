import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/data/models/review/review_model.dart';
import 'package:newapp/data/repositories/review_repository.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/review/review_state.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _reviewRepository;
  final UserCubit _userCubit;

  ReviewCubit({
    required ReviewRepository reviewRepository,
    required UserCubit userCubit,
  })  : _reviewRepository = reviewRepository,
        _userCubit = userCubit,
        super(ReviewInitial());

  // Method to add a review for a product
  Future<void> addReview({
    required String productId,
    int? rating, // Rating is nullable
    String? comment, // Comment is nullable
  }) async {
    emit(ReviewLoading());

    final userId = _userCubit.state is UserLoggedInState
        ? (_userCubit.state as UserLoggedInState).userModel.sId
        : null;

    if (userId == null) {
      emit(ReviewFailure(message: "User not logged in."));
      return;
    }

    try {
      // Call the repository method to add a review
      final review = await _reviewRepository.addReview(
        productId: productId,
        userId: userId,
        rating: rating, // Pass nullable rating
        comment: comment, // Pass nullable comment
      );

      // Emit success state with the added review
      emit(ReviewAddedSuccess(review: review));

      // Fetch the updated list of reviews after adding a new review
      await getProductReviews(productId: productId);

    } catch (ex) {
      emit(ReviewFailure(message: ex.toString())); // Error adding review
    }
  }

  // Method to get all reviews for a product
  Future<void> getProductReviews({required String productId}) async {
    emit(ReviewLoading());

    try {
      // Fetch reviews from the repository
      final reviews = await _reviewRepository.getProductReviews(
        productId: productId,
      );

      // Emit the state with reviews, without passing 'averageRating'
      emit(ReviewSuccess(reviews: reviews));
    } catch (ex) {
      emit(ReviewFailure(message: ex.toString())); // Error fetching reviews
    }
  }
}
