class DeliveryAddress {
  const DeliveryAddress({
    required this.line1,
    required this.city,
    required this.pincode,
    required this.phone,
    this.landmark = '',
  });

  final String line1;
  final String landmark;
  final String city;
  final String pincode;
  final String phone;

  bool get isComplete =>
      line1.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      pincode.trim().length == 6 &&
      phone.trim().length == 10;

  String get oneLine {
    final extra = landmark.trim().isEmpty ? '' : ', $landmark';
    return '$line1$extra, $city $pincode';
  }

  Map<String, dynamic> toJson() => {
        'line1': line1,
        'landmark': landmark,
        'city': city,
        'pincode': pincode,
        'phone': phone,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      line1: json['line1'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  static const empty = DeliveryAddress(
    line1: '',
    city: '',
    pincode: '',
    phone: '',
  );
}

enum PaymentMethod { cod, upi, card }
