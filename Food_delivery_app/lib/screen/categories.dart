import 'package:flutter/material.dart';
import 'package:khaanado/modles/food_categories_modle.dart';
import 'package:khaanado/screen/detail_page.dart';
import 'package:khaanado/screen/widget/bottom_Contianer.dart';

class Categories extends StatelessWidget {
  final List<FoodCategoriesModle> list;

  const Categories({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: list.isEmpty
          ? const Center(
              child: Text(
                'No items in this category',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return BottomContainer(
                  onTap: () {
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
                  },
                  image: item.image,
                  price: item.price,
                  name: item.name,
                );
              },
            ),
    );
  }
}
