import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/api_result.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/model/place_order_request.dart';
import 'package:khaanado/services/catalog_seed.dart';

typedef DelayFn = Future<void> Function(Duration duration);

class MockApiClient {
  MockApiClient({DelayFn? delay, this.forceFailNextOrder = false})
      : _delay = delay ?? _defaultDelay;

  final DelayFn _delay;
  bool forceFailNextOrder;
  int _orderSeq = 1001;

  static Future<void> _defaultDelay(Duration duration) =>
      Future<void>.delayed(duration);

  Future<ApiResult<CatalogPayload>> fetchCatalog() async {
    await _delay(const Duration(milliseconds: AppConstants.mockNetworkDelayMs));
    return ApiResult.ok(
      CatalogPayload(
        categories: CatalogSeed.categories,
        items: CatalogSeed.items,
      ),
    );
  }

  Future<ApiResult<Order>> placeOrder(PlaceOrderRequest request) async {
    await _delay(const Duration(milliseconds: AppConstants.mockNetworkDelayMs));
    if (forceFailNextOrder || request.shouldForceFail) {
      forceFailNextOrder = false;
      return ApiResult.fail(StringConstants.promoFailForced);
    }
    final id = 'KD$_orderSeq';
    _orderSeq += 1;
    return ApiResult.ok(
      Order(
        id: id,
        lines: List<CartLine>.from(request.lines),
        subtotal: request.subtotal,
        tax: request.tax,
        deliveryFee: request.deliveryFee,
        discount: request.discount,
        total: request.total,
        address: request.address,
        payment: request.payment,
        placedAt: DateTime.now(),
        status: OrderStatus.placed,
        promoCode: request.promoCode,
      ),
    );
  }
}

class CatalogPayload {
  const CatalogPayload({required this.categories, required this.items});

  final List<FoodCategory> categories;
  final List<FoodItem> items;
}
