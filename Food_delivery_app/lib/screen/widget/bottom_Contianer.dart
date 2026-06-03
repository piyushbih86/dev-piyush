import 'package:flutter/material.dart';
import 'package:khaanado/app_theme.dart';
import 'package:khaanado/screen/widget/app_food_image.dart';

class BottomContainer extends StatelessWidget {
  final String image;
  final String name;
  final int price;
  final VoidCallback onTap;

  const BottomContainer({
    super.key,
    required this.onTap,
    required this.image,
    required this.price,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: AppFoodImage(
                imagePath: image,
                name: name,
                expand: true,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 10),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < 4 ? Icons.star : Icons.star_border,
                    size: 14,
                    color: i < 4 ? AppColors.star : Colors.white24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
