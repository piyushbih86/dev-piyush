# KhaanaDo

Production-style Flutter food delivery app: catalog, cart, checkout, live order tracking, and auth.

Architecture follows the same patterns used in PlaySimple Play-to-Earn apps — thin screens, GetIt controllers, centralized constants, overlay toasters, `BasePopup`, and auto-surfacing (FTUE).

## Run

```bash
cd Food_delivery_app
flutter pub get
flutter run
```

Demo login: `demo@khaanado.app` / `Demo@123`  
Promo codes: `KHAANA10` (10% off), `FIRST50` (₹50 off over ₹199), `FAILME` (forced checkout error)

## Architecture

```
lib/
  constants/          # colors, copy, assets, routes, tracking events
  controller/         # auth, catalog, cart, orders, toaster
  model/              # domain + API request/result types
  services/           # storage, mock API, pricing, logger
  surfacing_manager/  # first-open FTUE (P2E-style auto-surface)
  ui/
    custom_widgets/   # button, toaster, nav, cards
    popups/           # BasePopup + feature popups
    screens/          # splash, auth, home, cart, checkout, tracking
```

- **Screens** own layout and lifecycle only.
- **Controllers** own business rules and persistence (`ChangeNotifier` + GetIt).
- **MockApiClient.placeOrder** uses an `onResponse(success, data, error)` callback, same shape as P2E API controllers.
- **Cart / session / orders** persist through `KeyValueStore` (SharedPreferences in app, `MemoryStore` in tests).

## Test

```bash
flutter test
```
