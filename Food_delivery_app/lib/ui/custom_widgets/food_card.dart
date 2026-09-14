import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/ui/custom_widgets/food_image.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.onAdd,
  });

  final FoodItem item;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: RepaintBoundary(
        child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConstants.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'food-${item.id}-${identityHashCode(this)}',
                    child: FoodImage(
                      imagePath: item.image,
                      name: item.name,
                      expand: true,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x990B0A09)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _VegBadge(isVeg: item.isVeg),
                  ),
                  if (onFavorite != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onFavorite!();
                        },
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? ColorConstants.accent
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4332),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onAdd != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _AddChip(onTap: onAdd!),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.kitchen} · ${item.prepMinutes} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorConstants.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    AppUtil.rupees(item.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConstants.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            StringConstants.add,
            style: TextStyle(
              color: ColorConstants.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _VegBadge extends StatelessWidget {
  const _VegBadge({required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? ColorConstants.veg : ColorConstants.nonVeg;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
