import 'package:flutter/foundation.dart';
import 'package:khaanado/model/diet_filter.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/services/mock_api_client.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this._api);

  final MockApiClient _api;

  List<FoodCategory> _categories = const [];
  List<FoodItem> _items = const [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  List<FoodCategory> get categories => _categories;
  List<FoodItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  bool get loaded => _loaded;

  List<FoodItem> get popular =>
      _items.where((item) => item.isPopular).toList(growable: false);

  List<FoodItem> get under150 =>
      _items.where((item) => item.price <= 150).toList(growable: false);

  List<FoodItem> get chefsTable =>
      _items.where((item) => item.rating >= 4.6).toList(growable: false);

  List<FoodItem> get midnightCravings => _items
      .where(
        (item) =>
            item.categoryId == 'dessert' ||
            item.categoryId == 'drinks' ||
            item.id == 'biryani',
      )
      .toList(growable: false);

  FoodItem? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<FoodItem> byCategory(String categoryId) {
    return _items
        .where((item) => item.categoryId == categoryId)
        .toList(growable: false);
  }

  ({String title, List<FoodItem> items}) resolveList(String id) {
    final category = categoryById(id);
    if (category != null) {
      return (title: category.name, items: byCategory(id));
    }
    switch (id) {
      case 'chefs':
        return (title: "Chef's table", items: chefsTable);
      case 'under150':
        return (title: 'Under ₹150', items: under150);
      case 'midnight':
        return (title: 'Midnight cravings', items: midnightCravings);
      case 'veg':
        return (
          title: 'Pure veg',
          items: _items.where((item) => item.isVeg).toList(growable: false),
        );
      case 'favorites':
        return (title: 'Your favourites', items: const []);
      default:
        return (title: 'Menu', items: _items);
    }
  }

  List<FoodItem> favoritesOf(Iterable<String> ids) {
    final wanted = ids.toSet();
    return _items.where((item) => wanted.contains(item.id)).toList();
  }

  FoodCategory? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<FoodItem> filterDiet(List<FoodItem> items, DietFilter filter) {
    return switch (filter) {
      DietFilter.all => List<FoodItem>.from(items),
      DietFilter.veg =>
        items.where((item) => item.isVeg).toList(growable: false),
      DietFilter.nonVeg =>
        items.where((item) => !item.isVeg).toList(growable: false),
    };
  }

  List<FoodItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where((item) {
          return item.name.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              item.categoryId.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await _api.fetchCatalog();
    if (result.success && result.data != null) {
      _categories = result.data!.categories;
      _items = result.data!.items;
      _loaded = true;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }
}
