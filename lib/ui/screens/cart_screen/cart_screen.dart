import 'package:flutter/material.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/empty_state.dart';
import 'package:khaanado/ui/custom_widgets/food_image.dart';
import 'package:khaanado/ui/custom_widgets/free_delivery_meter.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/custom_widgets/qty_stepper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promo = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartController.addListener(_refresh);
    if (cartController.promoCode != null) {
      _promo.text = cartController.promoCode!;
    }
  }

  @override
  void dispose() {
    cartController.removeListener(_refresh);
    _promo.dispose();
    super.dispose();
  }

  void _refresh() {
    appNotifiers.cartCount.value = cartController.itemCount;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cart = cartController;
    final totals = cart.totals;

    final body = cart.isEmpty
        ? EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: StringConstants.cartEmptyTitle,
            body: StringConstants.cartEmptyBody,
            actionLabel: StringConstants.browseMenu,
            onAction: () => appNotifiers.selectedTab.value = ShellTabs.home,
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              ...cart.lines.map((line) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorConstants.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ColorConstants.cardBorder),
                  ),
                  child: Row(
                    children: [
                      FoodImage(
                        imagePath: line.item.image,
                        name: line.item.name,
                        size: 64,
                        circular: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppUtil.rupees(line.lineTotal),
                              style: const TextStyle(
                                color: ColorConstants.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            QtyStepper(
                              quantity: line.quantity,
                              min: 0,
                              onChanged: (qty) =>
                                  cart.setQuantity(line.item.id, qty),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => cart.remove(line.item.id),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promo,
                      style: TextStyle(color: ColorConstants.textPrimary),
                      decoration: InputDecoration(
                        hintText: StringConstants.promoHint,
                        filled: true,
                        fillColor: ColorConstants.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final ok = cart.applyPromo(_promo.text);
                      toasterController.show(
                        context,
                        cart.promoMessage ?? StringConstants.promoInvalid,
                        kind: ok ? ToasterKind.success : ToasterKind.error,
                      );
                    },
                    child: const Text(StringConstants.apply),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PriceRow(StringConstants.subtotal, AppUtil.rupees(totals.subtotal)),
              _PriceRow(
                StringConstants.discount,
                totals.discount == 0 ? '—' : '- ${AppUtil.rupees(totals.discount)}',
              ),
              _PriceRow(
                StringConstants.deliveryFee,
                totals.deliveryFee == 0
                    ? StringConstants.free
                    : AppUtil.rupees(totals.deliveryFee),
              ),
              _PriceRow(StringConstants.tax, AppUtil.rupees(totals.tax)),
              const Divider(),
              _PriceRow(
                StringConstants.total,
                AppUtil.rupees(totals.total),
                bold: true,
              ),
              const SizedBox(height: 8),
              Text(
                '+${(totals.total / AppConstants.rupeesPerCoin).floor()} ${StringConstants.coins} on this order',
                style: const TextStyle(
                  color: ColorConstants.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final checkoutBar = cart.isEmpty
        ? null
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PrimaryButton(
              label:
                  '${StringConstants.checkout} · ${AppUtil.rupees(totals.total)}',
              onPressed: () =>
                  Navigator.pushNamed(context, RouteConstants.checkout),
            ),
          );

    if (widget.embedded) {
      return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    StringConstants.yourCart,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (!cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: FreeDeliveryMeter(
                    subtotal: cart.subtotal,
                    promoCode: cart.promoCode,
                    compact: true,
                  ),
                ),
          Expanded(child: body),
          if (checkoutBar != null) checkoutBar,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.yourCart)),
      body: body,
      bottomNavigationBar: checkoutBar,
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? ColorConstants.textPrimary : ColorConstants.textSecondary,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 18 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
