import 'package:ecomweb/presentation/screens/auth/providers/signup_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/ui.dart';
import '../../widgets/gap_widgets.dart';
import '../../widgets/primary_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/link_button.dart';

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

    return Scaffold(
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
              Text("Create Account", style: TextStyles.heading2(context)),
              const GapWidget(size: -10),

              // Display error message if available
              if (provider.error.isNotEmpty)
                Text(
                  provider.error,
                  style: const TextStyle(color: Colors.red),
                ),

              const GapWidget(size: 5),

              // Email input field
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

              // Password input field
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

              // Confirm Password input field
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

              // Create Account button
              PrimaryButton(
                onPressed: () => provider.createAccount(context),
                text: provider.isLoading ? "..." : "Create Account",
              ),

              const GapWidget(),

              // Login redirect link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyles.body2(context)),
                  const GapWidget(),
                  LinkButton(
                    onPressed: () {
                      // Navigate to login screen
                      Navigator.pushNamed(context, '/login');
                    },
                    text: "Log In",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
