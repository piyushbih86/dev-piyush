import 'dart:convert';

import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/delivery_address.dart';
import 'package:khaanado/model/diet_filter.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/model/user_profile.dart';
import 'package:khaanado/services/key_value_store.dart';

class LocalStorage {
  LocalStorage(this._store);

  final KeyValueStore _store;

  List<UserProfile> readUsers() {
    final raw = _store.getString(StorageKeys.users);
    if (raw == null || raw.isEmpty) return <UserProfile>[];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUsers(List<UserProfile> users) {
    return _store.setString(
      StorageKeys.users,
      jsonEncode(users.map((e) => e.toJson()).toList()),
    );
  }

  String? readSessionEmail() => _store.getString(StorageKeys.sessionEmail);

  Future<void> saveSessionEmail(String email) =>
      _store.setString(StorageKeys.sessionEmail, email);

  Future<void> clearSession() => _store.remove(StorageKeys.sessionEmail);

  bool readGuest() => _store.getString(StorageKeys.guest) == '1';

  Future<void> saveGuest(bool guest) =>
      _store.setString(StorageKeys.guest, guest ? '1' : '0');

  List<CartLine> readCart() {
    final raw = _store.getString(StorageKeys.cart);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartLine> lines) {
    return _store.setString(
      StorageKeys.cart,
      jsonEncode(lines.map((e) => e.toJson()).toList()),
    );
  }

  List<Order> readOrders() {
    final raw = _store.getString(StorageKeys.orders);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOrders(List<Order> orders) {
    return _store.setString(
      StorageKeys.orders,
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
  }

  DeliveryAddress readAddress() {
    final raw = _store.getString(StorageKeys.address);
    if (raw == null || raw.isEmpty) return DeliveryAddress.empty;
    return DeliveryAddress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveAddress(DeliveryAddress address) {
    return _store.setString(StorageKeys.address, jsonEncode(address.toJson()));
  }

  bool readFtueSeen() => _store.getString(StorageKeys.ftueSeen) == '1';

  Future<void> saveFtueSeen() => _store.setString(StorageKeys.ftueSeen, '1');

  String? readPromo() => _store.getString(StorageKeys.promo);

  Future<void> savePromo(String? code) {
    if (code == null || code.isEmpty) {
      return _store.remove(StorageKeys.promo);
    }
    return _store.setString(StorageKeys.promo, code);
  }

  LoyaltySnapshot readLoyalty() {
    final raw = _store.getString(StorageKeys.loyalty);
    if (raw == null || raw.isEmpty) return LoyaltySnapshot.empty;
    return LoyaltySnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLoyalty(LoyaltySnapshot snapshot) {
    return _store.setString(StorageKeys.loyalty, jsonEncode(snapshot.toJson()));
  }

  bool readDarkTheme() => _store.getString(StorageKeys.theme) != 'light';

  Future<void> saveDarkTheme(bool dark) {
    return _store.setString(StorageKeys.theme, dark ? 'dark' : 'light');
  }
}

class LoyaltySnapshot {
  const LoyaltySnapshot({
    required this.coins,
    required this.streak,
    required this.ordersPlaced,
    required this.lastOrderDay,
    required this.questDay,
    required this.claimed,
    required this.progress,
    required this.favorites,
    required this.dietFilter,
  });

  static const empty = LoyaltySnapshot(
    coins: 0,
    streak: 0,
    ordersPlaced: 0,
    lastOrderDay: null,
    questDay: '',
    claimed: [],
    progress: {},
    favorites: [],
    dietFilter: DietFilter.all,
  );

  final int coins;
  final int streak;
  final int ordersPlaced;
  final String? lastOrderDay;
  final String questDay;
  final List<String> claimed;
  final Map<String, int> progress;
  final List<String> favorites;
  final DietFilter dietFilter;

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'streak': streak,
        'ordersPlaced': ordersPlaced,
        'lastOrderDay': lastOrderDay,
        'questDay': questDay,
        'claimed': claimed,
        'progress': progress,
        'favorites': favorites,
        'dietFilter': dietFilter.name,
      };

  factory LoyaltySnapshot.fromJson(Map<String, dynamic> json) {
    final progressRaw = json['progress'] as Map<String, dynamic>? ?? {};
    return LoyaltySnapshot(
      coins: json['coins'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      ordersPlaced: json['ordersPlaced'] as int? ?? 0,
      lastOrderDay: json['lastOrderDay'] as String?,
      questDay: json['questDay'] as String? ?? '',
      claimed: (json['claimed'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      progress: progressRaw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      favorites: (json['favorites'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      dietFilter: DietFilter.fromStorage(
        json['dietFilter'] as String?,
        vegOnlyLegacy: json['vegOnly'] as bool? ?? false,
      ),
    );
  }
}
