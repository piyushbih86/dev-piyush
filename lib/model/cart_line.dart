import 'food_item.dart';

class CartLine {
  const CartLine({required this.item, required this.quantity});

  final FoodItem item;
  final int quantity;

  double get lineTotal => item.price * quantity;

  CartLine copyWith({FoodItem? item, int? quantity}) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'quantity': quantity,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      item: FoodItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}
