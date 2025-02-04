import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/user/user_state.dart'; // Ensure this import path is correct
import 'package:newapp/presentation/screens/auth/providers/signup_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocListener from flutter_bloc package
import 'package:provider/provider.dart';

import '../../../core/ui.dart';
import '../../widgets/gap_widgets.dart';
import '../../widgets/primary_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/link_button.dart';
import 'package:newapp/presentation/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = "signup";

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignupProvider>(context);

    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserCreatedState) {
          _showSuccessMessage(context); // Show success message via SnackBar
        }
        if (state is UserErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)), // Display error message via SnackBar
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text("Ecommerce App"),
        ),
        body: SafeArea(
          child: Form(
            key: provider.formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("Create Account", style: TextStyles.heading2),
                const GapWidget(size: -10),
                if (provider.error != "")
                  Text(
                    provider.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                const GapWidget(size: 5),
                PrimaryTextField(
                  controller: provider.emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email address is required!";
                    }

                    if (!EmailValidator.validate(value.trim())) {
                      return "Invalid email address";
                    }

                    return null;
                  },
                  labelText: "Email Address",
                ),
                const GapWidget(),
                PrimaryTextField(
                  controller: provider.passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Password is required!";
                    }
                    return null;
                  },
                  labelText: "Password",
                ),
                const GapWidget(),
                PrimaryTextField(
                  controller: provider.cPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Confirm your password!";
                    }

                    if (value.trim() != provider.passwordController.text.trim()) {
                      return "Passwords do not match!";
                    }

                    return null;
                  },
                  labelText: "Confirm Password",
                ),
                const GapWidget(),
                PrimaryButton(
                  onPressed: provider.createAccount,
                  text: provider.isLoading ? "..." : "Create Account",
                ),
                const GapWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyles.body2),
                    const GapWidget(),
                    LinkButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                      text: "Log In",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Success message when account is created (via SnackBar)
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Account Created Successfully! You can now log in."),
        backgroundColor: Colors.green, // Customize the background color
      ),
    );
  }
}
