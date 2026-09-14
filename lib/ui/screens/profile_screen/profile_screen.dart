import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/controller/toaster_controller.dart';
import 'package:khaanado/model/delivery_address.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/app_text_field.dart';
import 'package:khaanado/ui/custom_widgets/brand_mark.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_refresh);
    loyaltyController.addListener(_refresh);
    orderController.addListener(_refresh);
    themeController.addListener(_refresh);
  }

  @override
  void dispose() {
    authController.removeListener(_refresh);
    loyaltyController.removeListener(_refresh);
    orderController.removeListener(_refresh);
    themeController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    await authController.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.welcome,
      (route) => false,
    );
  }

  Future<void> _changePassword() async {
    if (!authController.isLoggedIn) {
      toasterController.show(
        context,
        StringConstants.login,
        kind: ToasterKind.info,
      );
      return;
    }
    final current = TextEditingController();
    final next = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorConstants.card,
          title: const Text(StringConstants.changePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: current,
                hint: 'Current password',
                obscure: true,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: next,
                hint: 'New password',
                obscure: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    final error = await authController.changePassword(
      current: current.text,
      next: next.text,
    );
    if (!mounted) return;
    toasterController.show(
      context,
      error ?? StringConstants.passwordUpdated,
      kind: error == null ? ToasterKind.success : ToasterKind.error,
    );
  }

  Future<void> _editAddress() async {
    final saved = orderController.address;
    final line1 = TextEditingController(text: saved.line1);
    final landmark = TextEditingController(text: saved.landmark);
    final city = TextEditingController(text: saved.city);
    final pincode = TextEditingController(text: saved.pincode);
    final phone = TextEditingController(text: saved.phone);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorConstants.card,
          title: const Text(StringConstants.savedAddress),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: line1,
                  hint: StringConstants.addressLine,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: landmark,
                  hint: StringConstants.landmark,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: city,
                  hint: StringConstants.city,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: pincode,
                  hint: StringConstants.pincode,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: phone,
                  hint: StringConstants.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    final address = DeliveryAddress(
      line1: line1.text,
      landmark: landmark.text,
      city: city.text,
      pincode: pincode.text,
      phone: phone.text,
    );
    final error = orderController.validateAddress(address);
    if (error != null) {
      toasterController.show(context, error, kind: ToasterKind.error);
      return;
    }
    await orderController.saveAddress(address);
    if (!mounted) return;
    toasterController.show(
      context,
      StringConstants.savedAddress,
      kind: ToasterKind.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = orderController.address;
    final loyalty = loyaltyController;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          StringConstants.profile,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ColorConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const BrandMark(size: 72),
        const SizedBox(height: 12),
        Text(
          authController.displayName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorConstants.textPrimary,
          ),
        ),
        Text(
          authController.displayEmail,
          style: TextStyle(color: ColorConstants.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConstants.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorConstants.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loyalty.isGold
                          ? StringConstants.goldMember
                          : StringConstants.coins,
                      style: const TextStyle(
                        color: ColorConstants.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${loyalty.coins} Gold',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: ColorConstants.accent,
                  ),
                  Text(
                    '${loyalty.streak} day streak',
                    style: TextStyle(
                      color: ColorConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            themeController.isDark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            color: ColorConstants.textSecondary,
          ),
          title: const Text(StringConstants.appearance),
          subtitle: Text(
            themeController.isDark
                ? StringConstants.darkTheme
                : StringConstants.lightTheme,
            style: TextStyle(color: ColorConstants.textSecondary),
          ),
          value: themeController.isDark,
          activeColor: ColorConstants.accent,
          onChanged: (dark) => themeController.setDark(dark),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.location_on_outlined,
            color: ColorConstants.textSecondary,
          ),
          title: const Text(StringConstants.savedAddress),
          subtitle: Text(
            address.isComplete ? address.oneLine : 'Tap to add an address',
            style: TextStyle(color: ColorConstants.textSecondary),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: ColorConstants.textMuted,
          ),
          onTap: _editAddress,
        ),
        if (authController.isLoggedIn)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.lock_outline,
              color: ColorConstants.textSecondary,
            ),
            title: const Text(StringConstants.changePassword),
            onTap: _changePassword,
          ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: StringConstants.logout,
          icon: Icons.logout,
          onPressed: _logout,
        ),
      ],
    );
  }
}
