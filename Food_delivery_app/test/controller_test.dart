import 'package:flutter_test/flutter_test.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/auth_controller.dart';
import 'package:khaanado/controller/cart_controller.dart';
import 'package:khaanado/controller/loyalty_controller.dart';
import 'package:khaanado/controller/order_controller.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/delivery_address.dart';
import 'package:khaanado/model/diet_filter.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/model/place_order_request.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/services/catalog_seed.dart';
import 'package:khaanado/services/key_value_store.dart';
import 'package:khaanado/services/local_storage.dart';
import 'package:khaanado/services/mock_api_client.dart';
import 'package:khaanado/services/pricing.dart';

FoodItem get _burger => CatalogSeed.items.first;

void main() {
  group('Pricing', () {
    test('applies KHAANA10 as 10 percent of subtotal', () {
      final totals = Pricing.totals(subtotal: 200, promoCode: 'khaana10');
      expect(totals.discount, 20);
      expect(totals.tax, 9);
      expect(totals.deliveryFee, AppConstants.deliveryFee);
      expect(totals.total, 200 - 20 + 9 + 40);
    });

    test('waives delivery at the ₹499 threshold', () {
      expect(Pricing.totals(subtotal: 498).deliveryFee, AppConstants.deliveryFee);
      expect(Pricing.totals(subtotal: 499).deliveryFee, 0);
    });

    test('free delivery uses the amount after discount', () {
      final totals = Pricing.totals(subtotal: 520, promoCode: 'KHAANA10');
      expect(totals.discount, 52);
      expect(totals.deliveryFee, AppConstants.deliveryFee);
      expect(Pricing.totals(subtotal: 560, promoCode: 'KHAANA10').deliveryFee, 0);
    });

    test('rejects FIRST50 below minimum subtotal', () {
      expect(Pricing.discountFor(subtotal: 100, promoCode: 'FIRST50'), 0);
      expect(Pricing.discountFor(subtotal: 199, promoCode: 'FIRST50'), 50);
    });
  });

  group('CartController', () {
    late CartController cart;

    setUp(() {
      cart = CartController(LocalStorage(MemoryStore()));
    });

    test('merges quantity for the same item', () async {
      await cart.add(_burger, quantity: 2);
      await cart.add(_burger, quantity: 1);
      expect(cart.lines.length, 1);
      expect(cart.lines.first.quantity, 3);
      expect(cart.itemCount, 3);
    });

    test('removing last quantity deletes the line', () async {
      await cart.add(_burger);
      await cart.setQuantity(_burger.id, 0);
      expect(cart.isEmpty, isTrue);
    });

    test('applyPromo accepts known codes and rejects junk', () async {
      await cart.add(_burger, quantity: 4);
      expect(cart.applyPromo('NOPE'), isFalse);
      expect(cart.applyPromo('KHAANA10'), isTrue);
      expect(cart.totals.discount, greaterThan(0));
    });

    test('persists cart across a new controller', () async {
      final store = MemoryStore();
      final first = CartController(LocalStorage(store));
      await first.add(_burger, quantity: 2);
      final second = CartController(LocalStorage(store));
      second.hydrate();
      expect(second.itemCount, 2);
      expect(second.lines.first.item.id, _burger.id);
    });
  });

  group('AuthController', () {
    late AuthController auth;

    setUp(() async {
      auth = AuthController(LocalStorage(MemoryStore()));
      await auth.hydrate();
    });

    test('seeds demo user and logs in', () async {
      expect(
        await auth.login(
          email: AppConstants.demoEmail,
          password: AppConstants.demoPassword,
        ),
        isNull,
      );
      expect(auth.isLoggedIn, isTrue);
      expect(auth.displayName, AppConstants.demoName);
    });

    test('login works even if hydrate was skipped', () async {
      final fresh = AuthController(LocalStorage(MemoryStore()));
      expect(
        await fresh.login(
          email: AppConstants.demoEmail,
          password: AppConstants.demoPassword,
        ),
        isNull,
      );
      expect(fresh.isLoggedIn, isTrue);
    });

    test('rejects bad password', () async {
      expect(
        await auth.login(email: AppConstants.demoEmail, password: 'wrong1'),
        StringConstants.loginFailed,
      );
    });

    test('signup then login round-trip', () async {
      expect(
        await auth.signup(
          name: 'Asha',
          email: 'asha@khaanado.app',
          password: 'secret1',
          confirm: 'secret1',
        ),
        isNull,
      );
      await auth.logout();
      expect(
        await auth.login(email: 'asha@khaanado.app', password: 'secret1'),
        isNull,
      );
    });
  });

  group('OrderController', () {
    test('placeOrder success persists and returns an id', () async {
      final storage = LocalStorage(MemoryStore());
      final api = MockApiClient(delay: (_) async {});
      final orders = OrderController(storage, api);
      final address = const DeliveryAddress(
        line1: '12 MG Road',
        city: 'Bengaluru',
        pincode: '560001',
        phone: '9876543210',
      );

      late bool ok;
      Order? placed;
      await orders.placeOrder(
        request: PlaceOrderRequest(
          lines: [CartLine(item: _burger, quantity: 1)],
          address: address,
          payment: PaymentMethod.cod,
          subtotal: 149,
          tax: 7.45,
          deliveryFee: 40,
          discount: 0,
          total: 196.45,
        ),
        onResponse: (success, data, error) {
          ok = success;
          placed = data;
        },
      );

      expect(ok, isTrue);
      expect(placed?.id, startsWith('KD'));
      expect(orders.orders, isNotEmpty);
    });

    test('FAILME promo surfaces an API error', () async {
      final orders = OrderController(
        LocalStorage(MemoryStore()),
        MockApiClient(delay: (_) async {}),
      );
      String? error;
      await orders.placeOrder(
        request: PlaceOrderRequest(
          lines: [CartLine(item: _burger, quantity: 1)],
          address: const DeliveryAddress(
            line1: '12 MG Road',
            city: 'Bengaluru',
            pincode: '560001',
            phone: '9876543210',
          ),
          payment: PaymentMethod.upi,
          subtotal: 149,
          tax: 7.45,
          deliveryFee: 40,
          discount: 0,
          total: 196.45,
          promoCode: 'FAILME',
        ),
        onResponse: (success, data, err) {
          error = err;
        },
      );
      expect(error, StringConstants.promoFailForced);
      expect(orders.orders, isEmpty);
    });

    test('status advances with elapsed time', () {
      final placedAt = DateTime(2026, 1, 1, 12, 0, 0);
      expect(
        OrderProgress.statusAt(placedAt, placedAt.add(const Duration(seconds: 3))),
        OrderStatus.placed,
      );
      expect(
        OrderProgress.statusAt(
          placedAt,
          placedAt.add(const Duration(seconds: 10)),
        ),
        OrderStatus.preparing,
      );
      expect(
        OrderProgress.statusAt(
          placedAt,
          placedAt.add(const Duration(seconds: 30)),
        ),
        OrderStatus.onTheWay,
      );
      expect(
        OrderProgress.statusAt(
          placedAt,
          placedAt.add(const Duration(seconds: 50)),
        ),
        OrderStatus.delivered,
      );
    });
  });

  group('LoyaltyController', () {
    final dessert =
        CatalogSeed.items.firstWhere((item) => item.categoryId == 'dessert');

    Order sampleOrder() {
      return Order(
        id: 'KDTEST',
        lines: [CartLine(item: _burger, quantity: 1)],
        subtotal: 149,
        tax: 7.45,
        deliveryFee: 40,
        discount: 0,
        total: 196.45,
        address: const DeliveryAddress(
          line1: '12 MG Road',
          city: 'Bengaluru',
          pincode: '560001',
          phone: '9876543210',
        ),
        payment: PaymentMethod.cod,
        placedAt: DateTime(2026, 1, 1),
        status: OrderStatus.placed,
      );
    }

    test('dessert in cart completes and claims Sweet tooth', () async {
      final storage = LocalStorage(MemoryStore());
      final loyalty = LoyaltyController(storage)..hydrate();
      final cart = CartController(storage, loyalty: loyalty);
      await cart.add(dessert);
      final quest = loyalty.quests.firstWhere(
        (item) => item.definition.id == QuestCatalog.sweetTooth,
      );
      expect(quest.complete, isTrue);
      expect(loyalty.claim(QuestCatalog.sweetTooth), isTrue);
      expect(loyalty.coins, 25);
      expect(loyalty.claim(QuestCatalog.sweetTooth), isFalse);
    });

    test('claimed daily quest stays complete after cart is emptied', () async {
      final storage = LocalStorage(MemoryStore());
      final loyalty = LoyaltyController(storage)..hydrate();
      final cart = CartController(storage, loyalty: loyalty);
      await cart.add(_burger, quantity: 3);
      expect(loyalty.claim(QuestCatalog.feastMode), isTrue);
      await cart.clear();
      final quest = loyalty.quests.firstWhere(
        (item) => item.definition.id == QuestCatalog.feastMode,
      );
      expect(quest.claimed, isTrue);
      expect(quest.displayProgress, 3);
    });

    test('favourites complete collector quest', () async {
      final loyalty = LoyaltyController(LocalStorage(MemoryStore()))
        ..hydrate();
      await loyalty.toggleFavorite('classic_burger');
      await loyalty.toggleFavorite('lava_cake');
      expect(loyalty.claim(QuestCatalog.collector), isTrue);
      expect(loyalty.coins, 20);
    });

    test('daily rewards reset countdown is until midnight', () {
      final loyalty = LoyaltyController(LocalStorage(MemoryStore()))
        ..hydrate();
      expect(
        loyalty.dailyResetLabel(now: DateTime(2026, 1, 1, 20, 10)),
        'Resets in 3h 50m',
      );
      expect(
        loyalty.dailyResetShort(now: DateTime(2026, 1, 1, 23, 40)),
        '20m',
      );
    });

    test('diet filter persists all veg and non-veg', () {
      final storage = LocalStorage(MemoryStore());
      final loyalty = LoyaltyController(storage)..hydrate();
      expect(loyalty.dietFilter, DietFilter.all);
      loyalty.setDietFilter(DietFilter.veg);
      final again = LoyaltyController(storage)..hydrate();
      expect(again.dietFilter, DietFilter.veg);
      again.setDietFilter(DietFilter.nonVeg);
      final third = LoyaltyController(storage)..hydrate();
      expect(third.dietFilter, DietFilter.nonVeg);
    });

    test('orders award coins and build a streak', () {
      final loyalty = LoyaltyController(LocalStorage(MemoryStore()))
        ..hydrate();
      loyalty.onOrderPlaced(sampleOrder(), now: DateTime(2026, 1, 1, 12));
      expect(loyalty.streak, 1);
      expect(loyalty.coins, 19);
      loyalty.onOrderPlaced(sampleOrder(), now: DateTime(2026, 1, 2, 12));
      expect(loyalty.streak, 2);
      loyalty.onOrderPlaced(sampleOrder(), now: DateTime(2026, 1, 6, 12));
      expect(loyalty.streak, 1);
    });
  });
}
