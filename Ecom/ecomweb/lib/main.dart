import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecomweb/logic/cubit/user/user_cubit.dart';
import 'package:ecomweb/logic/cubit/product/product_cubit.dart';
import 'package:ecomweb/logic/cubit/cart/cart_cubit.dart';
import 'package:ecomweb/logic/cubit/theme/theme_cubit.dart';
import 'package:ecomweb/presentation/screens/splash/splash_screen.dart';
import 'package:ecomweb/core/routes.dart';
import 'package:ecomweb/logic/cubit/order/order_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  EcommerceAppState createState() => EcommerceAppState();
}

class EcommerceAppState extends State<EcommerceApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => ProductCubit()),
        BlocProvider(create: (context) => CartCubit(BlocProvider.of<UserCubit>(context))),
        BlocProvider(create: (context) => OrderCubit(
          BlocProvider.of<UserCubit>(context),
          BlocProvider.of<CartCubit>(context),
        )),
        BlocProvider(create: (context) => ThemeCubit()), // Provide ThemeCubit
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRoute,
            initialRoute: SplashScreen.routeName,
            themeMode: themeState, // Apply the selected theme mode
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
          );
        },
      ),
    );
  }
}
