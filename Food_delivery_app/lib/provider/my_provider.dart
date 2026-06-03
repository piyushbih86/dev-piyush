import 'package:flutter/cupertino.dart';
import 'package:khaanado/modles/cart_modle.dart';
import 'package:khaanado/modles/categories_modle.dart';
import 'package:khaanado/modles/food_categories_modle.dart';
import 'package:khaanado/modles/food_modle.dart';

/// Bundled food photos in [assets/images/].
class FoodAssets {
  static const burger = 'assets/images/burger.jpg';
  static const burger2 = 'assets/images/burger2.jpg';
  static const pizza = 'assets/images/pizza.jpg';
  static const pizza2 = 'assets/images/pizza2.jpg';
  static const pasta = 'assets/images/pasta.jpg';
  static const biryani = 'assets/images/biryani.jpg';
  static const soda = 'assets/images/soda.jpg';
  static const coffee = 'assets/images/coffee.jpg';
  static const mojito = 'assets/images/mojito.jpg';
}

class MyProvider extends ChangeNotifier {
  final List<CategoriesModle> burgerList = [
    CategoriesModle(image: FoodAssets.burger, name: 'Burger'),
  ];
  Future<void> getBurgerCategory() async {}

  get throwBurgerList => burgerList;

  final List<CategoriesModle> recipeList = [
    CategoriesModle(image: FoodAssets.pasta, name: 'Recipe'),
  ];
  Future<void> getRecipeCategory() async {}

  get throwRecipeList => recipeList;

  final List<CategoriesModle> pizzaList = [
    CategoriesModle(image: FoodAssets.pizza, name: 'Pizza'),
  ];
  Future<void> getPizzaCategory() async {}

  get throwPizzaList => pizzaList;

  final List<CategoriesModle> drinkList = [
    CategoriesModle(image: FoodAssets.soda, name: 'Drink'),
  ];
  Future<void> getDrinkCategory() async {}

  get throwDrinkList => drinkList;

  final List<FoodModle> foodModleList = [
    FoodModle(name: 'Classic Burger', image: FoodAssets.burger, price: 8),
    FoodModle(name: 'Cheese Pizza', image: FoodAssets.pizza, price: 12),
    FoodModle(name: 'Pasta Bowl', image: FoodAssets.pasta, price: 10),
    FoodModle(name: 'Lemon Soda', image: FoodAssets.soda, price: 5),
  ];
  Future<void> getFoodList() async {}

  get throwFoodModleList => foodModleList;

  final List<FoodCategoriesModle> burgerCategoriesList = [
    FoodCategoriesModle(
      image: FoodAssets.burger,
      name: 'Crunch Burger',
      price: 9,
    ),
    FoodCategoriesModle(
      image: FoodAssets.burger2,
      name: 'Smoky Burger',
      price: 11,
    ),
  ];
  Future<void> getBurgerCategoriesList() async {}

  get throwBurgerCategoriesList => burgerCategoriesList;

  final List<FoodCategoriesModle> recipeCategoriesList = [
    FoodCategoriesModle(
      image: FoodAssets.pasta,
      name: 'Pasta Alfredo',
      price: 14,
    ),
    FoodCategoriesModle(
      image: FoodAssets.biryani,
      name: 'Paneer Rice',
      price: 13,
    ),
  ];
  Future<void> getrecipeCategoriesList() async {}

  get throwRecipeCategoriesList => recipeCategoriesList;

  final List<FoodCategoriesModle> pizzaCategoriesList = [
    FoodCategoriesModle(
      image: FoodAssets.pizza,
      name: 'Veggie Pizza',
      price: 15,
    ),
    FoodCategoriesModle(
      image: FoodAssets.pizza2,
      name: 'Farmhouse Pizza',
      price: 16,
    ),
  ];
  Future<void> getPizzaCategoriesList() async {}

  get throwPizzaCategoriesList => pizzaCategoriesList;

  final List<FoodCategoriesModle> drinkCategoriesList = [
    FoodCategoriesModle(
      image: FoodAssets.coffee,
      name: 'Cold Coffee',
      price: 7,
    ),
    FoodCategoriesModle(
      image: FoodAssets.mojito,
      name: 'Fresh Mojito',
      price: 6,
    ),
  ];
  Future<void> getDrinkCategoriesList() async {}

  get throwDrinkCategoriesList => drinkCategoriesList;

  List<CartModle> cartList = [];
  late CartModle cartModle;

  void addToCart({
    required String image,
    required String name,
    required int price,
    required int quantity,
  }) {
    cartModle = CartModle(
      image: image,
      name: name,
      price: price,
      quantity: quantity,
    );
    cartList.add(cartModle);
    notifyListeners();
  }

  get throwCartList => cartList;

  int totalprice() {
    int total = 0;
    for (final element in cartList) {
      total += element.price * element.quantity;
    }
    return total;
  }

  void deleteAt(int index) {
    cartList.removeAt(index);
    notifyListeners();
  }
}
