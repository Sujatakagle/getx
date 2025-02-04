
import 'package:newapp/data/models/user/user_model.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/presentation/widgets/link_button.dart';
import 'package:newapp/presentation/screens/user/edit_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newapp/logic/cubit/theme/theme_cubit.dart';
import 'package:newapp/presentation/screens/order/my_order_screen.dart';

class TextStyles {
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(builder: (context, state) {
      if (state is UserLoadingState) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is UserErrorState) {
        return Center(child: Text(state.message));
      }

      if (state is UserLoggedInState) {
        return userProfile(state.userModel);
      }

      return const Center(child: Text("An error occurred!"));
    });
  }

  Widget userProfile(UserModel userModel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image is no longer clickable or changeable
            CircleAvatar(
              radius: 60,
              backgroundImage: userModel.profileImage != null && userModel.profileImage!.isNotEmpty
                  ? CachedNetworkImageProvider(userModel.profileImage ?? '')
                  : const NetworkImage('https://via.placeholder.com/150') as ImageProvider<Object>,
            ),
            const SizedBox(height: 5),
            Text(
              "${userModel.fullName}",
              style: TextStyles.heading3.copyWith(fontSize: 25, fontWeight: FontWeight.w600), // Increased size and weight
            ),
            const SizedBox(height: 3),
            Text(
              "${userModel.email}",
              style: TextStyles.body2.copyWith(fontSize: 18, fontWeight: FontWeight.w500), // Increased size and weight
            ),
            const SizedBox(height: 1),
            LinkButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProfileScreen.routeName);
              },
              text: "Edit Profile",  // Pass a String here, not a Text widget
            ),
            const SizedBox(height: 3),
          ],
        ),
        const Divider(),
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, MyOrderScreen.routeName);
          },
          contentPadding: EdgeInsets.zero,
          leading: const Icon(CupertinoIcons.cube_box_fill),
          title: Text("My Orders", style: TextStyles.body1.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),

        const SizedBox(height: 5),
        const Divider(),
        // Notification Settings Section

        // Theme Settings Section
        ListTile(
          onTap: () {
            // Toggle theme
            BlocProvider.of<ThemeCubit>(context).toggleTheme();
          },
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.brightness_6),
          title: Text("Theme", style: TextStyles.body1),
          trailing: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return Icon(
                themeMode == ThemeMode.dark ? Icons.nightlight_round : Icons.wb_sunny,
                size: 16,
              );
            },
          ),
        ),
        const Divider(),
        // Sign Out Section moved to bottom
        ListTile(
          onTap: () {
            BlocProvider.of<UserCubit>(context).signOut();
          },
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: Text("Sign Out", style: TextStyles.body1.copyWith(color: Colors.red)),
        ),
      ],
    );
  }
}
