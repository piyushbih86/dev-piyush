import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/model/order.dart';

class Pricing {
  Pricing._();

  static double discountFor({
    required double subtotal,
    String? promoCode,
  }) {
    if (promoCode == null || promoCode.isEmpty) return 0;
    final code = promoCode.toUpperCase();
    if (code == AppConstants.promoForceFailCode) return 0;
    if (code == AppConstants.promoPercentCode) {
      return _round(subtotal * AppConstants.promoPercentValue);
    }
    if (code == AppConstants.promoFlatCode &&
        subtotal >= AppConstants.promoFlatMinSubtotal) {
      return AppConstants.promoFlatValue.clamp(0, subtotal).toDouble();
    }
    return 0;
  }

  static bool isKnownPromo(String code) {
    final value = code.trim().toUpperCase();
    return value == AppConstants.promoPercentCode ||
        value == AppConstants.promoFlatCode ||
        value == AppConstants.promoForceFailCode;
  }

  static double deliveryFee(double subtotalAfterDiscount) {
    if (subtotalAfterDiscount >= AppConstants.freeDeliveryMin) return 0;
    return AppConstants.deliveryFee;
  }

  static double tax(double taxable) => _round(taxable * AppConstants.gstRate);

  static double _round(double value) =>
      double.parse(value.toStringAsFixed(2));

  static CartTotals totals({
    required double subtotal,
    String? promoCode,
  }) {
    final discount = discountFor(subtotal: subtotal, promoCode: promoCode);
    final afterDiscount = subtotal - discount;
    final fee = deliveryFee(afterDiscount);
    final gst = tax(afterDiscount);
    return CartTotals(
      subtotal: _round(subtotal),
      discount: discount,
      deliveryFee: fee,
      tax: gst,
      total: _round(afterDiscount + fee + gst),
    );
  }
}

class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;
}

class OrderProgress {
  OrderProgress._();

  static OrderStatus statusAt(DateTime placedAt, DateTime now) {
    final elapsed = now.difference(placedAt).inSeconds;
    if (elapsed >= AppConstants.deliveredAfterSec) return OrderStatus.delivered;
    if (elapsed >= AppConstants.onTheWayAfterSec) return OrderStatus.onTheWay;
    if (elapsed >= AppConstants.preparingAfterSec) return OrderStatus.preparing;
    return OrderStatus.placed;
  }
}
