import 'dart:async';
import 'package:ecomweb/logic/cubit/user/user_cubit.dart';
import 'package:ecomweb/logic/cubit/user/user_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupProvider with ChangeNotifier {
  bool isLoading = false;
  String error = "";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  StreamSubscription? _userSubscription;

  void _listenToUserCubit(BuildContext context) {
    _userSubscription = BlocProvider.of<UserCubit>(context).stream.listen((userState) {
      if (userState is UserLoadingState) {
        isLoading = true;
        error = "";
        notifyListeners();
      } else if (userState is UserErrorState) {
        isLoading = false;
        error = userState.message;
        notifyListeners();
      } else {
        isLoading = false;
        error = "";
        notifyListeners();
      }
    });
  }

  void createAccount(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    BlocProvider.of<UserCubit>(context).createAccount(email: email, password: password);
  }

  void startListening(BuildContext context) {
    _listenToUserCubit(context);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
