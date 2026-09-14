import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/ui/app_router.dart';
import 'package:khaanado/ui/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupLocator();
    runApp(const KhaanadoApp());
  }, (error, stack) {
    AppLogger.error('uncaught', error, stack);
  });
}

class KhaanadoApp extends StatelessWidget {
  const KhaanadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: catalogController),
        ChangeNotifierProvider.value(value: cartController),
        ChangeNotifierProvider.value(value: orderController),
        ChangeNotifierProvider.value(value: loyaltyController),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: StringConstants.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.mode,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}

/// Kept so existing test imports of `MyApp` still compile if referenced.
typedef MyApp = KhaanadoApp;
