import 'package:flutter/material.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/ui/custom_widgets/brand_mark.dart';
import 'package:khaanado/ui/screens/shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = RouteConstants.splash;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _boot();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    AppTracker.track(TrackingStrings.appLaunch);
    await Future.wait([
      authController.hydrate(),
      catalogController.load(),
      Future<void>.delayed(const Duration(milliseconds: AppConstants.splashMs)),
    ]);
    loyaltyController.hydrate();
    cartController.hydrate();
    orderController.hydrate();
    themeController.hydrate();
    appNotifiers.cartCount.value = cartController.itemCount;
    if (!mounted) return;
    if (authController.hasSession) {
      Navigator.of(context).pushReplacementNamed(AppShell.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteConstants.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: ColorConstants.headerGradient),
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 96),
                  const SizedBox(height: 18),
                  const Text(
                    StringConstants.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    StringConstants.tagline,
                    style: TextStyle(color: ColorConstants.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
