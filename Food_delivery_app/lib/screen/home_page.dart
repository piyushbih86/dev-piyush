import 'package:flutter/material.dart';
import 'package:khaanado/app_theme.dart';
import 'package:khaanado/modles/food_categories_modle.dart';
import 'package:khaanado/modles/food_modle.dart';
import 'package:khaanado/provider/my_provider.dart';
import 'package:khaanado/screen/cart_page.dart';
import 'package:khaanado/screen/categories.dart';
import 'package:khaanado/screen/detail_page.dart';
import 'package:khaanado/screen/widget/app_food_image.dart';
import 'package:khaanado/screen/widget/bottom_Contianer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _categoryChip({
    required BuildContext context,
    required String image,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppFoodImage(
                imagePath: image,
                name: name,
                size: 72,
                circular: false,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({required String name, required IconData icon}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        name,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  void _openCategory(
    BuildContext context,
    List<FoodCategoriesModle> list,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Categories(list: list)),
    );
  }

  void _openDetail(BuildContext context, FoodModle item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          image: item.image,
          name: item.name,
          price: item.price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();
    final categories = [
      ...provider.throwBurgerList,
      ...provider.throwRecipeList,
      ...provider.throwPizzaList,
      ...provider.throwDrinkList,
    ];
    final categoryLists = [
      provider.throwBurgerCategoriesList,
      provider.throwRecipeCategoriesList,
      provider.throwPizzaCategoriesList,
      provider.throwDrinkCategoriesList,
    ];
    final foods = provider.throwFoodModleList;

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: AppColors.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.card),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.person, color: Colors.white, size: 36),
                ),
                accountName: const Text('KhaanaDo User'),
                accountEmail: const Text('hello@khaanado.app'),
              ),
              _drawerItem(icon: Icons.person, name: 'Profile'),
              _drawerItem(
                icon: Icons.add_shopping_cart,
                name: 'Cart',
              ),
              _drawerItem(icon: Icons.shop, name: 'Orders'),
              const Divider(),
              _drawerItem(icon: Icons.lock, name: 'Change password'),
              _drawerItem(icon: Icons.exit_to_app, name: 'Log out'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'KhaanaDo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search food...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final list = index < categoryLists.length
                      ? categoryLists[index]
                      : provider.throwBurgerCategoriesList;
                  return _categoryChip(
                    context: context,
                    image: item.image,
                    name: item.name,
                    onTap: () => _openCategory(context, list),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Popular near you',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: foods.isEmpty
                  ? const Center(
                      child: Text(
                        'No items yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final item = foods[index];
                        return BottomContainer(
                          onTap: () => _openDetail(context, item),
                          image: item.image,
                          price: item.price,
                          name: item.name,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
