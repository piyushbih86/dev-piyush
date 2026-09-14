import 'package:flutter/material.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/service_locator.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cart = cartController;
    if (cart.isEmpty) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: ColorConstants.buttonGradient,
            boxShadow: [
              BoxShadow(
                color: ColorConstants.accent.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} · ${AppUtil.rupees(cart.totals.total)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Text(
                  StringConstants.viewBag,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
