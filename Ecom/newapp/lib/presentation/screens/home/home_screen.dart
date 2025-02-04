import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/presentation/screens/cart/cart_screen.dart';
import 'package:newapp/Presentation/screens/home/user_feed_screen.dart';
import 'package:newapp/presentation/screens/home/category_screen.dart';
import 'package:newapp/Presentation/screens/home/profile_feed_screen.dart';
import 'package:newapp/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:newapp/logic/cubit/user/user_state.dart';
import 'package:newapp/logic/cubit/cart/cart_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Widget> screens = const [
    UserFeedScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoggedOutState) {
          Navigator.pushReplacementNamed(context, SplashScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ev Chargers"),
          backgroundColor: Colors.blueGrey, // Set AppBar background color
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
              icon: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return Badge(
                    label: Text("${state.items.length}"),
                    isLabelVisible: (state is CartLoadingState) ? false : true,
                    child: const Icon(CupertinoIcons.cart_fill),
                  );
                },
              ),
            ),
          ],
        ),
        body: screens[currentIndex], // Correct placement of body
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: "Categories",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}