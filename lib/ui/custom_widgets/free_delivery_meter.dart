import 'package:flutter/material.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/services/pricing.dart';

class FreeDeliveryMeter extends StatelessWidget {
  const FreeDeliveryMeter({
    super.key,
    required this.subtotal,
    this.promoCode,
    this.compact = false,
  });

  final double subtotal;
  final String? promoCode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final totals = Pricing.totals(subtotal: subtotal, promoCode: promoCode);
    final qualifying = totals.subtotal - totals.discount;
    final remaining = AppConstants.freeDeliveryMin - qualifying;
    final unlocked = totals.deliveryFee == 0 || remaining <= 0;
    final progress =
        (qualifying / AppConstants.freeDeliveryMin).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: ColorConstants.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? ColorConstants.success.withValues(alpha: 0.35)
              : ColorConstants.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unlocked
                ? StringConstants.freeDeliveryUnlocked
                : '₹${remaining.ceil()} ${StringConstants.moreForFreeDelivery}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 14,
              color: unlocked ? ColorConstants.success : ColorConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: ColorConstants.surface,
                color: unlocked ? ColorConstants.success : ColorConstants.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
