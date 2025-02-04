import 'package:newapp/data/models/user/user_model.dart';
import 'package:newapp/data/repositories/user_repository.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:newapp/logic/services/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitialState()) {
    _initialize();
  }

  final UserRepository _userRepository = UserRepository();

  // Initialize function to check saved user details
  void _initialize() async {
    try {
      final userDetails = await Preferences.fetchUserDetails();
      String? email = userDetails["email"];
      String? password = userDetails["password"];

      if (email == null || password == null) {
        emit(UserLoggedOutState());
      } else {
        signIn(email: email, password: password); // No await here
      }
    } catch (ex) {
      emit(UserErrorState("Initialization failed"));
    }
  }

  // SignIn function
  void signIn({
    required String email,
    required String password,
  }) async {
    emit(UserLoadingState());
    try {
      UserModel userModel = await _userRepository.signIn(email: email, password: password);
      await Preferences.saveUserDetails(email, password);
      emit(UserLoggedInState(userModel));
    } catch (ex) {
      await Preferences.clear();
      emit(UserErrorState("Sign-in failed"));
    }
  }

  // Create account function
  void createAccount({
    required String email,
    required String password,
  }) async {
    emit(UserLoadingState());
    try {
      await _userRepository.createAccount(email: email, password: password);
      // Clear error state and log the user out to show the login screen
      emit(UserLoggedOutState());
    } catch (ex) {
      if (ex.toString().contains("User already exists")) {
        emit(UserErrorState("User already exists"));
      } else {
        emit(UserErrorState("Account creation failed"));
      }
    }
  }

  // Update user function
  Future<bool> updateUser(UserModel userModel) async {
    emit(UserLoadingState());
    try {
      UserModel updatedUser = await _userRepository.updateUser(userModel);
      emit(UserLoggedInState(updatedUser));
      return true;
    } catch (ex) {
      emit(UserErrorState("Update failed"));
      return false;
    }
  }

  // SignOut function
  void signOut() async {
    await Preferences.clear();
    emit(UserLoggedOutState());
  }

  // Clear error state manually (for login screen)
  void clearErrorState() {
    emit(UserInitialState()); // Reset to initial state to clear error messages
  }
}