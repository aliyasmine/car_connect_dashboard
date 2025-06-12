import 'package:car_conect_dashboard/core/utils/app_shared_preferences.dart';
import 'package:car_conect_dashboard/feature/main/screen/main_screen.dart';
import 'package:flutter/material.dart';

import '../feature/auth/screen/login_screen.dart';
import '../feature/business/screens/business_details_screen.dart';
import '../feature/car/screens/car_details_screen.dart';
import '../feature/car/screens/cars_screen.dart';
import '../feature/orders/screens/orders_screen.dart';
import '../feature/reservations/screens/reservations_screen.dart';
import '../feature/statistics/screens/statistics_screen.dart';

abstract class RouteNamedScreens {
  static String get init => AppSharedPreferences.getToken() == null ? "/login" : "/main";
  static const String splash = "/splash";
  static const String main = "/main";
  static const String profile = "/profile";
  static const String myOrders = "/myOrders";
  static const String carDetails = "/car-details";
  static const String login = "/login";
  static const String personalInfo = "/personal-info";
  static const String home = "/home";
  static const String verification = "/verification";
  static const String addCar = "/add-car";
  static const String myCars = "/myCars";
  static const String carOrders = "/car-orders";
  static const String myFavorites = "/my-favorites";
  static const String cart = "/my-cart";
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/cars':
        return MaterialPageRoute(builder: (_) => const CarsScreen());
      case '/car-details':
        final args = settings.arguments as CarDetailsArgs;
        return MaterialPageRoute(
            builder: (_) => CarDetailsScreen(args: args));
      case '/business-details':
        final businessId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => BusinessDetailsScreen(
                args: BusinessDetailsArgs(businessId: businessId)));
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case '/reservations':
        return MaterialPageRoute(builder: (_) => const ReservationsScreen());
      case '/statistics':
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
    }
    return null;
  }
}

abstract class CurrentRoute {
  static String? currentRouteName;

  CurrentRoute({required String currentRouteName});
}
