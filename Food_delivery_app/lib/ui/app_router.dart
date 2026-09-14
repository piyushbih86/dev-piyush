import 'package:flutter/material.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/ui/screens/auth/auth_screens.dart';
import 'package:khaanado/ui/screens/catalog_screen/catalog_screen.dart';
import 'package:khaanado/ui/screens/checkout_screen/checkout_screen.dart';
import 'package:khaanado/ui/screens/detail_screen/detail_screen.dart';
import 'package:khaanado/ui/screens/orders_screen/orders_screen.dart';
import 'package:khaanado/ui/screens/shell/app_shell.dart';
import 'package:khaanado/ui/screens/splash_screen/splash_screen.dart';
import 'package:khaanado/ui/screens/welcome_screen/welcome_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return _fade(const SplashScreen());
      case RouteConstants.welcome:
        return _fade(const WelcomeScreen());
      case RouteConstants.login:
        return _slide(const LoginScreen());
      case RouteConstants.signup:
        return _slide(const SignupScreen());
      case RouteConstants.shell:
        return _fade(const AppShell());
      case RouteConstants.catalog:
        return _slide(CatalogScreen(categoryId: settings.arguments as String));
      case RouteConstants.search:
        return _slide(const SearchScreen());
      case RouteConstants.detail:
        return _slide(DetailScreen(item: settings.arguments as FoodItem));
      case RouteConstants.checkout:
        return _slide(const CheckoutScreen());
      case RouteConstants.tracking:
        return _slide(
          OrderTrackingScreen(orderId: settings.arguments as String),
        );
      default:
        return _fade(const SplashScreen());
    }
  }

  static Route<dynamic> _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<dynamic> _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}
