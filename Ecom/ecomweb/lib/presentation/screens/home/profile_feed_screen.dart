import 'dart:io';
import 'package:ecomweb/core/ui.dart';
import 'package:ecomweb/data/models/user/user_model.dart';
import 'package:ecomweb/logic/cubit/user/user_cubit.dart';
import 'package:ecomweb/logic/cubit/user/user_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecomweb/presentation/widgets/link_button.dart';
import 'package:ecomweb/presentation/screens/user/edit_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:ecomweb/presentation/screens/ser/languages.dart'; // Import for the languages screen
import 'package:ecomweb/logic/cubit/theme/theme_cubit.dart';
import 'package:ecomweb/Presentation/screens/order/my_order_screen.dart';

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
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery or camera
  Future<void> _pickImage() async {
    try {
      final pickedFile = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pick an image'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(ImageSource.camera),
                child: Text('Camera'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
                child: Text('Gallery'),
              ),
            ],
          );
        },
      );
      if (pickedFile != null) {
        final XFile? file = await _picker.pickImage(source: pickedFile);
        if (file != null) {
          setState(() {
            _profileImage = File(file.path);
          });
        }
      }
    } catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image')));
    }
  }

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
            GestureDetector(
              onTap: _pickImage, // Allow image picking on tap
              child: CircleAvatar(
                radius: 60,
                // Larger radius for better visibility
                backgroundImage: _profileImage == null
                    ? (userModel.profileImage != null &&
                    userModel.profileImage!.isNotEmpty)
                    ? CachedNetworkImageProvider(userModel.profileImage ?? '')
                    : const NetworkImage('https://via.placeholder.com/150') as ImageProvider<Object>
                    : FileImage(_profileImage!) as ImageProvider<Object>,
                // Use FileImage if the user selected an image
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${userModel.fullName}",
              style: TextStyles.heading3.copyWith(fontSize: 25, fontWeight: FontWeight.w600), // Increased size and weight
            ),
            const SizedBox(height: 8),
            Text(
              "${userModel.email}",
              style: TextStyles.body2.copyWith(fontSize: 18, fontWeight: FontWeight.w500), // Increased size and weight
            ),
            const SizedBox(height: 5),
            LinkButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProfileScreen.routeName);
              },
              text: "Edit Profile",  // Pass a String here, not a Text widget
            ),
            const SizedBox(height: 10),
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
        // Account Settings Section
        Text(
          "Account Settings",
          style: TextStyles.heading2.copyWith(fontWeight: FontWeight.w500, fontSize: 24),
        ),
        const SizedBox(height: 16),
        // Select Language Section
        const Divider(),
        // Notification Settings Section
        ListTile(
          onTap: () {
            // Handle notification settings
          },
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications),
          title: Text("Notification Settings", style: TextStyles.body1,),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        const Divider(),
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
