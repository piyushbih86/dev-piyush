import 'package:get_it/get_it.dart';
import 'package:khaanado/controller/auth_controller.dart';
import 'package:khaanado/controller/cart_controller.dart';
import 'package:khaanado/controller/catalog_controller.dart';
import 'package:khaanado/controller/loyalty_controller.dart';
import 'package:khaanado/controller/order_controller.dart';
import 'package:khaanado/controller/theme_controller.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/services/key_value_store.dart';
import 'package:khaanado/services/local_storage.dart';
import 'package:khaanado/services/mock_api_client.dart';
import 'package:khaanado/surfacing_manager/home_auto_surfacing_manager.dart';
import 'package:khaanado/ui/common/app_change_notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  await setupLocatorWithStore(SharedPrefsStore(prefs));
}

Future<void> setupLocatorWithStore(
  KeyValueStore store, {
  MockApiClient? api,
}) async {
  await sl.reset();
  sl.registerSingleton<KeyValueStore>(store);
  sl.registerSingleton<LocalStorage>(LocalStorage(store));
  sl.registerSingleton<MockApiClient>(api ?? MockApiClient());
  sl.registerSingleton<AppChangeNotifiers>(AppChangeNotifiers());
  sl.registerSingleton<ToasterController>(ToasterController());
  sl.registerSingleton<AuthController>(AuthController(sl<LocalStorage>()));
  sl.registerSingleton<CatalogController>(
    CatalogController(sl<MockApiClient>()),
  );
  final cart = CartController(sl<LocalStorage>());
  sl.registerSingleton<CartController>(cart);
  final loyalty = LoyaltyController(sl<LocalStorage>());
  sl.registerSingleton<LoyaltyController>(loyalty);
  cart.bindLoyalty(loyalty);
  sl.registerSingleton<OrderController>(
    OrderController(
      sl<LocalStorage>(),
      sl<MockApiClient>(),
      loyalty: loyalty,
    ),
  );
  sl.registerSingleton<HomeAutoSurfacingManager>(
    HomeAutoSurfacingManager(sl<LocalStorage>()),
  );
  final theme = ThemeController(sl<LocalStorage>())..hydrate();
  sl.registerSingleton<ThemeController>(theme);
}

AuthController get authController => sl<AuthController>();
CatalogController get catalogController => sl<CatalogController>();
CartController get cartController => sl<CartController>();
LoyaltyController get loyaltyController => sl<LoyaltyController>();
OrderController get orderController => sl<OrderController>();
ToasterController get toasterController => sl<ToasterController>();
AppChangeNotifiers get appNotifiers => sl<AppChangeNotifiers>();
HomeAutoSurfacingManager get homeSurfacing => sl<HomeAutoSurfacingManager>();
ThemeController get themeController => sl<ThemeController>();
