import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';

class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.imagePath,
    required this.name,
    this.size = 80,
    this.circular = false,
    this.expand = false,
    this.fit = BoxFit.cover,
    this.radius = 12,
    this.heroTag,
  });

  final String imagePath;
  final String name;
  final double size;
  final bool circular;
  final bool expand;
  final BoxFit fit;
  final double radius;
  final String? heroTag;

  static IconData iconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('burger')) return Icons.lunch_dining;
    if (n.contains('pizza')) return Icons.local_pizza;
    if (n.contains('pasta') || n.contains('rice') || n.contains('biryani')) {
      return Icons.ramen_dining;
    }
    if (n.contains('dosa')) return Icons.breakfast_dining;
    if (n.contains('drink') ||
        n.contains('soda') ||
        n.contains('coffee') ||
        n.contains('mojito')) {
      return Icons.local_cafe;
    }
    if (n.contains('cake') || n.contains('dessert')) return Icons.cake;
    return Icons.restaurant;
  }

  Widget _placeholder() {
    return ColoredBox(
      color: ColorConstants.surface,
      child: Center(
        child: Icon(
          iconForName(name),
          size: size * 0.42,
          color: ColorConstants.accent,
        ),
      ),
    );
  }

  Widget _image() {
    return Image.asset(
      imagePath,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget built = expand
        ? SizedBox.expand(child: _image())
        : SizedBox(width: size, height: size, child: _image());
    if (circular) {
      built = ClipOval(child: built);
    } else {
      built = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: built,
      );
    }
    if (heroTag == null) return built;
    return Hero(tag: heroTag!, child: built);
  }
}
