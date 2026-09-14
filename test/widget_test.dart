import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/key_value_store.dart';
import 'package:khaanado/services/mock_api_client.dart';
import 'package:khaanado/ui/app_router.dart';
import 'package:khaanado/ui/app_theme.dart';
import 'package:khaanado/ui/screens/welcome_screen/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupLocatorWithStore(
      MemoryStore({StorageKeys.ftueSeen: '1'}),
      api: MockApiClient(delay: (_) async {}),
    );
    await authController.hydrate();
    await catalogController.load();
    cartController.hydrate();
    loyaltyController.hydrate();
    orderController.hydrate();
    themeController.hydrate();
  });

  testWidgets('welcome guest path opens the home catalog', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authController),
          ChangeNotifierProvider.value(value: catalogController),
          ChangeNotifierProvider.value(value: cartController),
          ChangeNotifierProvider.value(value: orderController),
          ChangeNotifierProvider.value(value: loyaltyController),
          ChangeNotifierProvider.value(value: themeController),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          home: const WelcomeScreen(),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );

    expect(find.text(StringConstants.welcomeTitle), findsOneWidget);

    await tester.tap(find.text(StringConstants.continueGuest));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(
      find.text(StringConstants.popularNearYou, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Classic Burger', skipOffstage: false), findsOneWidget);
  });
}
