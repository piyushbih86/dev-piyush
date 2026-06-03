import 'package:flutter/material.dart';
import 'package:food_course/app_theme.dart';

class BottomContainer extends StatelessWidget {
  final String image;
  final String name;
  final int price;
  final Function() onTap;
  BottomContainer({super.key, required this. onTap,required this. image, required this. price, required this.name});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
          child: Container(
        height: 270,
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(image),
            ),
            ListTile(
              leading: Text(
                name,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              trailing: Text(
                "\$$price",
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 18, color: AppColors.star),
                  const Icon(Icons.star, size: 18, color: AppColors.star),
                  const Icon(Icons.star, size: 18, color: AppColors.star),
                  const Icon(Icons.star, size: 18, color: AppColors.star),
                  Icon(Icons.star, size: 18, color: Colors.white24),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}