import 'package:ecomweb/data/models/product/product_model.dart';
import 'package:ecomweb/presentation/screens/auth/providers/login_provider.dart';
import 'package:ecomweb/Presentation/screens/products/product_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecomweb/presentation/screens/auth/login_screen.dart';
import 'package:ecomweb/presentation/screens/auth/signup_screen.dart';
import 'package:ecomweb/presentation/screens/home/home_screen.dart';  // Import HomeScreen
import 'package:ecomweb/presentation/screens/splash/splash_screen.dart'; // Import SplashScreen
import 'package:provider/provider.dart';
import 'package:ecomweb/presentation/screens/auth/providers/signup_provider.dart';
import 'package:ecomweb/presentation/screens/cart/cart_screen.dart';
import 'package:ecomweb/Presentation/screens/user/edit_profile_screen.dart';
import 'package:ecomweb/Presentation/screens/order/order_detail_screen.dart';
import 'package:ecomweb/Presentation/screens/order/my_order_screen.dart';
import 'package:ecomweb/Presentation/screens/order/order_placed_screen.dart';
import 'package:ecomweb/Presentation/screens/order/provider/order_detail_provider.dart';
class Routes {
  static Route? onGenerateRoute(RouteSettings settings) {
    switch(settings.name) {
      case LoginScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => LoginProvider(),
            child: const LoginScreen(),
          ),
        );

      case SignupScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => SignupProvider(),
            child: const SignupScreen(),
          ),
        );

      case HomeScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => const HomeScreen(),
        );

      case SplashScreen.routeName:
        return CupertinoPageRoute(
          builder: (context) => const SplashScreen(),
        );

      case ProductDetailsScreen.routeName:  // Updated to new route name
        return CupertinoPageRoute(
          builder: (context) => ProductDetailsScreen(
            productModel: settings.arguments as ProductModel, // Correct parameter name
          ),
        );

      case CartScreen.routeName:
        return CupertinoPageRoute(
            builder: (context) => const CartScreen()  // Ensure CartScreen is correctly imported and used
        );

      case EditProfileScreen.routeName:
        return CupertinoPageRoute(
            builder: (context) => const EditProfileScreen()  // Ensure EditProfileScreen is correctly imported and used
        );

      case OrderDetailScreen.routeName: return CupertinoPageRoute(
          builder: (context) => ChangeNotifierProvider(
              create: (context) => OrderDetailProvider(),
              child: const OrderDetailScreen()
          )
      );

      case OrderPlacedScreen.routeName: return CupertinoPageRoute(
          builder: (context) => const OrderPlacedScreen()
      );

      case MyOrderScreen.routeName: return CupertinoPageRoute(
          builder: (context) => const MyOrderScreen()
      );
      default:
        return null;
    }
  }
}
