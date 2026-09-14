class FoodCategory {
  const FoodCategory({
    required this.id,
    required this.name,
    required this.image,
  });

  final String id;
  final String name;
  final String image;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.prepMinutes,
    required this.categoryId,
    required this.description,
    required this.isVeg,
    required this.isPopular,
    required this.reviewCount,
    this.kitchen = 'Neighbourhood kitchen',
  });

  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final int prepMinutes;
  final String categoryId;
  final String description;
  final bool isVeg;
  final bool isPopular;
  final int reviewCount;
  final String kitchen;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'price': price,
        'rating': rating,
        'prepMinutes': prepMinutes,
        'categoryId': categoryId,
        'description': description,
        'isVeg': isVeg,
        'isPopular': isPopular,
        'reviewCount': reviewCount,
        'kitchen': kitchen,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      prepMinutes: json['prepMinutes'] as int,
      categoryId: json['categoryId'] as String,
      description: json['description'] as String,
      isVeg: json['isVeg'] as bool,
      isPopular: json['isPopular'] as bool,
      reviewCount: json['reviewCount'] as int,
      kitchen: json['kitchen'] as String? ?? 'Neighbourhood kitchen',
    );
  }
}
