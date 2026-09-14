import 'cart_line.dart';
import 'delivery_address.dart';

enum OrderStatus { placed, preparing, onTheWay, delivered, cancelled }

class Order {
  const Order({
    required this.id,
    required this.lines,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.address,
    required this.payment,
    required this.placedAt,
    required this.status,
    this.promoCode,
  });

  final String id;
  final List<CartLine> lines;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double total;
  final DeliveryAddress address;
  final PaymentMethod payment;
  final DateTime placedAt;
  final OrderStatus status;
  final String? promoCode;

  int get itemCount =>
      lines.fold<int>(0, (sum, line) => sum + line.quantity);

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      lines: lines,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      address: address,
      payment: payment,
      placedAt: placedAt,
      status: status ?? this.status,
      promoCode: promoCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lines': lines.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'total': total,
        'address': address.toJson(),
        'payment': payment.name,
        'placedAt': placedAt.toIso8601String(),
        'status': status.name,
        'promoCode': promoCode,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      address: DeliveryAddress.fromJson(json['address'] as Map<String, dynamic>),
      payment: PaymentMethod.values.byName(json['payment'] as String),
      placedAt: DateTime.parse(json['placedAt'] as String),
      status: OrderStatus.values.byName(json['status'] as String),
      promoCode: json['promoCode'] as String?,
    );
  }
}
