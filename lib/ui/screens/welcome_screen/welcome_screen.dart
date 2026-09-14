import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/brand_mark.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/screens/shell/app_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = RouteConstants.welcome;

  Future<void> _guest(BuildContext context) async {
    await authController.continueAsGuest();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppShell.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: ColorConstants.headerGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FadeSlideIn(child: BrandMark(size: 84)),
                const SizedBox(height: 22),
                const FadeSlideIn(
                  delay: Duration(milliseconds: 80),
                  child: Text(
                    StringConstants.appName,
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorConstants.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const FadeSlideIn(
                  delay: Duration(milliseconds: 140),
                  child: Text(
                    StringConstants.welcomeTitle,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    StringConstants.welcomeBody,
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorConstants.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  child: PrimaryButton(
                    label: StringConstants.login,
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteConstants.login),
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteConstants.signup),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(StringConstants.signup),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => _guest(context),
                    child: const Text(StringConstants.continueGuest),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
