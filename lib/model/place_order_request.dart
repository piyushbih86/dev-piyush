import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/model/cart_line.dart';
import 'package:khaanado/model/delivery_address.dart';

class PlaceOrderRequest {
  const PlaceOrderRequest({
    required this.lines,
    required this.address,
    required this.payment,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.promoCode,
  });

  final List<CartLine> lines;
  final DeliveryAddress address;
  final PaymentMethod payment;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? promoCode;

  bool get shouldForceFail =>
      promoCode?.toUpperCase() == AppConstants.promoForceFailCode;
}
