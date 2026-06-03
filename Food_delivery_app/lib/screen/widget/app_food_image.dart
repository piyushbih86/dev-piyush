import 'package:flutter/material.dart';
import 'package:khaanado/app_theme.dart';

/// Shows a bundled asset, network URL, or icon fallback.
class AppFoodImage extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double? size;
  final bool circular;
  final bool expand;
  final BoxFit fit;

  const AppFoodImage({
    super.key,
    this.imagePath,
    required this.name,
    this.size = 80,
    this.circular = false,
    this.expand = false,
    this.fit = BoxFit.cover,
  });

  static IconData iconForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('burger')) return Icons.lunch_dining;
    if (n.contains('pizza')) return Icons.local_pizza;
    if (n.contains('pasta') || n.contains('recipe') || n.contains('rice')) {
      return Icons.ramen_dining;
    }
    if (n.contains('drink') ||
        n.contains('soda') ||
        n.contains('coffee') ||
        n.contains('mojito')) {
      return Icons.local_cafe;
    }
    return Icons.restaurant;
  }

  bool get _isAsset =>
      imagePath != null && imagePath!.startsWith('assets/');

  bool get _isNetwork =>
      imagePath != null &&
      (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));

  bool get _hasImage => _isAsset || _isNetwork;

  Widget _placeholder() {
    return Container(
      width: expand ? double.infinity : size,
      height: expand ? double.infinity : size,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        iconForName(name),
        size: (size ?? 80) * 0.45,
        color: AppColors.accent,
      ),
    );
  }

  Widget _buildImage() {
    if (_isAsset) {
      return Image.asset(
        imagePath!,
        fit: fit,
        width: expand ? double.infinity : size,
        height: expand ? double.infinity : size,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (_isNetwork) {
      return Image.network(
        imagePath!,
        fit: fit,
        width: expand ? double.infinity : size,
        height: expand ? double.infinity : size,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: expand ? double.infinity : size,
            height: expand ? double.infinity : size,
            color: AppColors.surface,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent.withOpacity(0.7),
            ),
          );
        },
      );
    }
    return _placeholder();
  }

  @override
  Widget build(BuildContext context) {
    final image = _hasImage ? _buildImage() : _placeholder();

    if (expand) {
      final expanded = SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: image,
      );
      if (circular) {
        return ClipOval(child: expanded);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: expanded,
      );
    }

    final sized = SizedBox(width: size, height: size, child: image);
    if (circular) {
      return ClipOval(child: sized);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: sized,
    );
  }
}
