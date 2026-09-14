import 'package:flutter/foundation.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/controller/loyalty_controller.dart';
import 'package:khaanado/model/delivery_address.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/model/place_order_request.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/services/local_storage.dart';
import 'package:khaanado/services/mock_api_client.dart';
import 'package:khaanado/services/pricing.dart';
import 'package:khaanado/app_util.dart';

class OrderController extends ChangeNotifier {
  OrderController(this._storage, this._api, {LoyaltyController? loyalty})
      : _loyalty = loyalty;

  final LocalStorage _storage;
  final MockApiClient _api;
  final LoyaltyController? _loyalty;

  final List<Order> _orders = [];
  DeliveryAddress _address = DeliveryAddress.empty;
  PaymentMethod _payment = PaymentMethod.cod;
  bool _placing = false;

  List<Order> get orders => List.unmodifiable(_orders);
  DeliveryAddress get address => _address;
  PaymentMethod get payment => _payment;
  bool get placing => _placing;

  Order? get liveOrder {
    for (final order in _orders) {
      if (order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled) {
        return order;
      }
    }
    return null;
  }

  void hydrate() {
    _orders
      ..clear()
      ..addAll(_storage.readOrders());
    _address = _storage.readAddress();
    _tickStatuses();
    notifyListeners();
  }

  void _tickStatuses() {
    final now = DateTime.now();
    for (var i = 0; i < _orders.length; i++) {
      final current = _orders[i];
      if (current.status == OrderStatus.cancelled ||
          current.status == OrderStatus.delivered) {
        continue;
      }
      _orders[i] = current.copyWith(
        status: OrderProgress.statusAt(current.placedAt, now),
      );
    }
  }

  void refreshStatuses() {
    final before = _orders.map((order) => order.status).toList(growable: false);
    _tickStatuses();
    var changed = false;
    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i].status != before[i]) {
        changed = true;
        break;
      }
    }
    if (!changed) return;
    notifyListeners();
    _storage.saveOrders(_orders);
  }

  Order? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> saveAddress(DeliveryAddress address) async {
    _address = address;
    await _storage.saveAddress(address);
    notifyListeners();
  }

  void setPayment(PaymentMethod method) {
    _payment = method;
    notifyListeners();
  }

  String? validateAddress(DeliveryAddress address) {
    if (address.line1.trim().isEmpty || address.city.trim().isEmpty) {
      return StringConstants.addressRequired;
    }
    if (!AppUtil.isValidPincode(address.pincode)) {
      return StringConstants.pincodeInvalid;
    }
    if (!AppUtil.isValidPhone(address.phone)) {
      return StringConstants.phoneInvalid;
    }
    return null;
  }

  Future<void> placeOrder({
    required PlaceOrderRequest request,
    required void Function(bool success, Order? data, String? error) onResponse,
  }) async {
    _placing = true;
    notifyListeners();
    try {
      final result = await _api.placeOrder(request);
      if (!result.success || result.data == null) {
        AppTracker.track(TrackingStrings.orderPlaceFail);
        onResponse(false, null, result.error ?? StringConstants.genericError);
        return;
      }
      _orders.insert(0, result.data!);
      await _storage.saveOrders(_orders);
      _loyalty?.onOrderPlaced(result.data!);
      AppTracker.track(TrackingStrings.orderPlaceSuccess, {
        'id': result.data!.id,
        'total': result.data!.total,
      });
      onResponse(true, result.data, null);
    } catch (error, stack) {
      AppLogger.error('placeOrder', error, stack);
      onResponse(false, null, StringConstants.genericError);
    } finally {
      _placing = false;
      notifyListeners();
    }
  }
}
