import 'package:flutter/material.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/constants/tracking_strings.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/delivery_address.dart';
import 'package:khaanado/model/place_order_request.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/services/app_logger.dart';
import 'package:khaanado/ui/custom_widgets/app_text_field.dart';
import 'package:khaanado/ui/custom_widgets/empty_state.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/popups/app_popups.dart';
import 'package:khaanado/ui/screens/shell/app_shell.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const routeName = RouteConstants.checkout;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _line1;
  late final TextEditingController _landmark;
  late final TextEditingController _city;
  late final TextEditingController _pincode;
  late final TextEditingController _phone;
  bool _useSaved = false;

  @override
  void initState() {
    super.initState();
    final address = orderController.address;
    _useSaved = address.isComplete;
    _line1 = TextEditingController(text: address.line1);
    _landmark = TextEditingController(text: address.landmark);
    _city = TextEditingController(text: address.city);
    _pincode = TextEditingController(text: address.pincode);
    _phone = TextEditingController(text: address.phone);
    AppTracker.track(TrackingStrings.checkoutStart);
    orderController.addListener(_refresh);
  }

  @override
  void dispose() {
    orderController.removeListener(_refresh);
    _line1.dispose();
    _landmark.dispose();
    _city.dispose();
    _pincode.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  DeliveryAddress _draft() {
    return DeliveryAddress(
      line1: _line1.text,
      landmark: _landmark.text,
      city: _city.text,
      pincode: _pincode.text,
      phone: _phone.text,
    );
  }

  Future<void> _place() async {
    if (cartController.isEmpty) {
      toasterController.show(
        context,
        StringConstants.cartRequired,
        kind: ToasterKind.error,
      );
      return;
    }
    final address = _useSaved && orderController.address.isComplete
        ? orderController.address
        : _draft();
    final addressError = orderController.validateAddress(address);
    if (addressError != null) {
      toasterController.show(context, addressError, kind: ToasterKind.error);
      return;
    }
    await orderController.saveAddress(address);
    final totals = cartController.totals;
    final request = PlaceOrderRequest(
      lines: cartController.lines,
      address: address,
      payment: orderController.payment,
      subtotal: totals.subtotal,
      tax: totals.tax,
      deliveryFee: totals.deliveryFee,
      discount: totals.discount,
      total: totals.total,
      promoCode: cartController.promoCode,
    );

    await orderController.placeOrder(
      request: request,
      onResponse: (success, order, error) async {
        if (!mounted) return;
        if (!success || order == null) {
          toasterController.show(
            context,
            error ?? StringConstants.genericError,
            kind: ToasterKind.error,
          );
          return;
        }
        await cartController.clear();
        appNotifiers.cartCount.value = 0;
        if (!mounted) return;
        await OrderSuccessPopup.show(
          context,
          orderId: order.id,
          onTrack: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppShell.routeName,
              (route) => false,
            );
            appNotifiers.selectedTab.value = ShellTabs.orders;
            Navigator.of(context).pushNamed(
              RouteConstants.tracking,
              arguments: order.id,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = cartController.totals;
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.checkout)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              const Text(
                StringConstants.deliveryAddress,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              if (orderController.address.isComplete) ...[
                const SizedBox(height: 12),
                _AddressChoice(
                  selected: _useSaved,
                  title: StringConstants.useSavedAddress,
                  subtitle: orderController.address.oneLine,
                  onTap: () => setState(() => _useSaved = true),
                ),
                const SizedBox(height: 8),
                _AddressChoice(
                  selected: !_useSaved,
                  title: StringConstants.newAddress,
                  subtitle: 'Enter a different delivery location',
                  onTap: () => setState(() => _useSaved = false),
                ),
              ],
              if (!_useSaved || !orderController.address.isComplete) ...[
              const SizedBox(height: 12),
              AppTextField(
                controller: _line1,
                hint: StringConstants.addressLine,
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _landmark,
                hint: StringConstants.landmark,
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _city,
                hint: StringConstants.city,
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _pincode,
                hint: StringConstants.pincode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _phone,
                hint: StringConstants.phone,
                keyboardType: TextInputType.phone,
              ),
              ],
              const SizedBox(height: 24),
              const Text(
                StringConstants.payment,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...PaymentMethod.values.map((method) {
                final label = switch (method) {
                  PaymentMethod.cod => StringConstants.payCod,
                  PaymentMethod.upi => StringConstants.payUpi,
                  PaymentMethod.card => StringConstants.payCard,
                };
                return RadioListTile<PaymentMethod>(
                  value: method,
                  groupValue: orderController.payment,
                  onChanged: (value) {
                    if (value != null) orderController.setPayment(value);
                  },
                  title: Text(label),
                  fillColor: const WidgetStatePropertyAll(ColorConstants.accent),
                );
              }),
              const Divider(),
              Text(
                '${StringConstants.total}  ${AppUtil.rupees(totals.total)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          LoadingOverlay(
            visible: orderController.placing,
            label: StringConstants.applying,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PrimaryButton(
          label: StringConstants.placeOrder,
          loading: orderController.placing,
          onPressed: orderController.placing ? null : _place,
        ),
      ),
    );
  }
}

class _AddressChoice extends StatelessWidget {
  const _AddressChoice({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConstants.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? ColorConstants.accent : ColorConstants.cardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? ColorConstants.accent
                  : ColorConstants.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
