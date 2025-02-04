import 'package:ecomweb/core/ui.dart';
import 'package:ecomweb/data/models/user/user_model.dart';
import 'package:ecomweb/logic/cubit/user/user_cubit.dart';
import 'package:ecomweb/logic/cubit/user/user_state.dart';
import 'package:ecomweb/presentation/widgets/gap_widgets.dart';
import 'package:ecomweb/presentation/widgets/primary_button.dart';
import 'package:ecomweb/presentation/widgets/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = "edit_profile";

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UserErrorState) {
              return Center(child: Text(state.message));
            }

            if (state is UserLoggedInState) {
              return editProfile(state.userModel, context); // Pass context here
            }

            return const Center(child: Text("An error occurred!"));
          },
        ),
      ),
    );
  }

  Widget editProfile(UserModel userModel, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Personal Details",
          style: TextStyles.body1(context).copyWith(fontWeight: FontWeight.bold), // Use body1 with context and then copyWith
        ),
        const GapWidget(size: 10),
        PrimaryTextField(
          initialValue: userModel.fullName,
          onChanged: (value) {
            userModel.fullName = value;
          },
          labelText: "Full Name",
        ),
        const GapWidget(),
        PrimaryTextField(
          initialValue: userModel.phoneNumber,
          onChanged: (value) {
            userModel.phoneNumber = value;
          },
          labelText: "Phone Number",
        ),

        const GapWidget(size: 10),
        Text(
          "Address",
          style: TextStyles.body1(context).copyWith(fontWeight: FontWeight.bold), // Use body1 with context and then copyWith
        ),
        const GapWidget(size: 10),
        PrimaryTextField(
          initialValue: userModel.address,
          onChanged: (value) {
            userModel.address = value;
          },
          labelText: "Address",
        ),
        const GapWidget(),
        PrimaryTextField(
          initialValue: userModel.city,
          onChanged: (value) {
            userModel.city = value;
          },
          labelText: "City",
        ),
        const GapWidget(),
        PrimaryTextField(
          initialValue: userModel.state,
          onChanged: (value) {
            userModel.state = value;
          },
          labelText: "State",
        ),
        const GapWidget(),
        PrimaryButton(
          onPressed: () async {
            bool success = await BlocProvider.of<UserCubit>(context).updateUser(userModel);
            if (success) {
              Navigator.pop(context);
            }
          },
          text: "Save",
        ),
      ],
    );
  }
}
