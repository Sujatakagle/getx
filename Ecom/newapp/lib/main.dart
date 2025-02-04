import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newapp/logic/cubit/user/user_cubit.dart';
import 'package:newapp/logic/cubit/product/product_cubit.dart';
import 'package:newapp/logic/cubit/cart/cart_cubit.dart';
import 'package:newapp/logic/cubit/order/order_cubit.dart';
import 'package:newapp/logic/cubit/theme/theme_cubit.dart';
import 'package:newapp/presentation/screens/splash/splash_screen.dart';
import 'package:newapp/core/routes.dart';

import 'package:newapp/logic/cubit/review/review_cubit.dart';
import 'package:newapp/data/repositories/review_repository.dart';
import 'package:newapp/logic/cubit/category/category_cubit.dart';

// Import ReviewRepository

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  _EcommerceAppState createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  @override
  void initState() {
    super.initState();
    // Perform any initialization logic here, such as loading data or triggering cubit actions
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ReviewRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => UserCubit()),
          BlocProvider(create: (context) => ProductCubit()),
          BlocProvider(create: (context) => CategoryCubit()),
          BlocProvider(create: (context) => CartCubit(BlocProvider.of<UserCubit>(context))),
          BlocProvider(create: (context) => OrderCubit(BlocProvider.of<UserCubit>(context), BlocProvider.of<CartCubit>(context))),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(
            create: (context) => ReviewCubit(
              reviewRepository: RepositoryProvider.of<ReviewRepository>(context),
              userCubit: BlocProvider.of<UserCubit>(context),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode,
              onGenerateRoute: Routes.onGenerateRoute,
              initialRoute: SplashScreen.routeName,
            );
          },
        ),
      ),
    );
  }
}