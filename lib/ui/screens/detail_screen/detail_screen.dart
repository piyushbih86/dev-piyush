import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/food_item.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/food_image.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/custom_widgets/qty_stepper.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.item});

  static const routeName = RouteConstants.detail;

  final FoodItem item;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _qty = 1;
  bool _addedPulse = false;

  @override
  void initState() {
    super.initState();
    loyaltyController.addListener(_refresh);
  }

  @override
  void dispose() {
    loyaltyController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _add() async {
    await cartController.add(widget.item, quantity: _qty);
    appNotifiers.cartCount.value = cartController.itemCount;
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _addedPulse = true);
    toasterController.show(
      context,
      '${widget.item.name} · ${StringConstants.addedToCart}',
      kind: ToasterKind.success,
    );
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (mounted) setState(() => _addedPulse = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final fav = loyaltyController.isFavorite(item.id);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => loyaltyController.toggleFavorite(item.id),
            icon: Icon(
              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav ? ColorConstants.accent : ColorConstants.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.86, end: 1),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Hero(
                  tag: 'food-${item.id}',
                  child: FoodImage(
                    imagePath: item.image,
                    name: item.name,
                    size: 200,
                    circular: true,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: ColorConstants.card,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        item.isVeg
                            ? StringConstants.veg
                            : StringConstants.nonVeg,
                        style: TextStyle(
                          color: item.isVeg
                              ? ColorConstants.veg
                              : ColorConstants.nonVeg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    item.kitchen,
                    style: const TextStyle(
                      color: ColorConstants.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: ColorConstants.star,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating} (${item.reviewCount} ${StringConstants.reviews})',
                        style: TextStyle(
                          color: ColorConstants.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${item.prepMinutes} ${StringConstants.mins}',
                        style: TextStyle(
                          color: ColorConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      QtyStepper(
                        quantity: _qty,
                        onChanged: (value) => setState(() => _qty = value),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          AppUtil.rupees(item.price * _qty),
                          key: ValueKey(_qty),
                          style: const TextStyle(
                            color: ColorConstants.accent,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    StringConstants.description,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: ColorConstants.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  AnimatedScale(
                    scale: _addedPulse ? 1.04 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: PrimaryButton(
                      label: _addedPulse
                          ? StringConstants.addedToCart
                          : StringConstants.addToCart,
                      icon: _addedPulse
                          ? Icons.check_rounded
                          : Icons.shopping_bag_outlined,
                      onPressed: _add,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
