import 'package:flutter/foundation.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/controller/loyalty_controller.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/services/local_storage.dart';
import 'package:khaanado/services/pricing.dart';

class CartController extends ChangeNotifier {
  CartController(this._storage, {LoyaltyController? loyalty})
      : _loyalty = loyalty;

  final LocalStorage _storage;
  LoyaltyController? _loyalty;

  void bindLoyalty(LoyaltyController loyalty) {
    _loyalty = loyalty;
  }

  final List<CartLine> _lines = [];
  String? _promoCode;
  String? _promoMessage;

  List<CartLine> get lines => List.unmodifiable(_lines);
  String? get promoCode => _promoCode;
  String? get promoMessage => _promoMessage;
  bool get isEmpty => _lines.isEmpty;
  int get itemCount =>
      _lines.fold<int>(0, (sum, line) => sum + line.quantity);

  double get subtotal =>
      _lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  CartTotals get totals =>
      Pricing.totals(subtotal: subtotal, promoCode: _promoCode);

  void hydrate() {
    _lines
      ..clear()
      ..addAll(_storage.readCart());
    _promoCode = _storage.readPromo();
    notifyListeners();
    _syncLoyalty();
  }

  Future<void> _persist() async {
    await _storage.saveCart(_lines);
    await _storage.savePromo(_promoCode);
  }

  Future<void> add(FoodItem item, {int quantity = 1}) async {
    final qty = quantity.clamp(1, AppConstants.maxQty);
    final index = _lines.indexWhere((line) => line.item.id == item.id);
    if (index >= 0) {
      final next = (_lines[index].quantity + qty).clamp(1, AppConstants.maxQty);
      _lines[index] = _lines[index].copyWith(quantity: next);
    } else {
      _lines.add(CartLine(item: item, quantity: qty));
    }
    AppTracker.track(TrackingStrings.addToCart, {
      'id': item.id,
      'qty': qty,
    });
    notifyListeners();
    _syncLoyalty();
    await _persist();
  }

  Future<void> setQuantity(String foodId, int quantity) async {
    final index = _lines.indexWhere((line) => line.item.id == foodId);
    if (index < 0) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].copyWith(
        quantity: quantity.clamp(1, AppConstants.maxQty),
      );
    }
    notifyListeners();
    _syncLoyalty();
    await _persist();
  }

  Future<void> remove(String foodId) async {
    _lines.removeWhere((line) => line.item.id == foodId);
    notifyListeners();
    _syncLoyalty();
    await _persist();
  }

  Future<void> clear() async {
    _lines.clear();
    _promoCode = null;
    _promoMessage = null;
    notifyListeners();
    _syncLoyalty();
    await _persist();
  }

  bool applyPromo(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty || !Pricing.isKnownPromo(code)) {
      _promoMessage = StringConstants.promoInvalid;
      notifyListeners();
      return false;
    }
    if (code == AppConstants.promoFlatCode &&
        subtotal < AppConstants.promoFlatMinSubtotal) {
      _promoMessage = StringConstants.promoInvalid;
      notifyListeners();
      return false;
    }
    _promoCode = code;
    _promoMessage = StringConstants.promoApplied;
    AppTracker.track(TrackingStrings.promoApply, {'code': code});
    notifyListeners();
    _syncLoyalty();
    _persist();
    return true;
  }

  Future<void> replaceWith(List<CartLine> lines) async {
    _lines
      ..clear()
      ..addAll(lines);
    notifyListeners();
    _syncLoyalty();
    await _persist();
  }

  void _syncLoyalty() {
    _loyalty?.syncFromCart(lines: _lines, promoCode: _promoCode);
  }
}
