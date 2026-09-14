import 'package:flutter/material.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/app_nav_bar.dart';
import 'package:khaanado/ui/custom_widgets/floating_cart_bar.dart';
import 'package:khaanado/ui/screens/cart_screen/cart_screen.dart';
import 'package:khaanado/ui/screens/home_screen/home_screen.dart';
import 'package:khaanado/ui/screens/orders_screen/orders_screen.dart';
import 'package:khaanado/ui/screens/profile_screen/profile_screen.dart';
import 'package:khaanado/ui/screens/rewards_screen/rewards_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const routeName = RouteConstants.shell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final Set<int> _builtTabs = {ShellTabs.home};

  @override
  void initState() {
    super.initState();
    appNotifiers.selectedTab.value = ShellTabs.home;
    appNotifiers.selectedTab.addListener(_onTab);
    cartController.addListener(_syncCart);
  }

  @override
  void dispose() {
    appNotifiers.selectedTab.removeListener(_onTab);
    cartController.removeListener(_syncCart);
    super.dispose();
  }

  void _onTab() {
    final index = appNotifiers.selectedTab.value;
    _builtTabs.add(index);
    if (mounted) setState(() {});
  }

  void _syncCart() {
    appNotifiers.cartCount.value = cartController.itemCount;
  }

  Widget _tab(int index, Widget child) {
    if (_builtTabs.contains(index)) return child;
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final index = appNotifiers.selectedTab.value;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: index,
              children: [
                const HomeScreen(),
                _tab(ShellTabs.quests, const RewardsScreen()),
                _tab(ShellTabs.orders, const OrdersScreen()),
                _tab(ShellTabs.cart, const CartScreen(embedded: true)),
                _tab(ShellTabs.profile, const ProfileScreen()),
              ],
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                cartController,
                appNotifiers.selectedTab,
              ]),
              builder: (context, _) {
                final tab = appNotifiers.selectedTab.value;
                if (cartController.isEmpty || tab == ShellTabs.cart) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: FloatingCartBar(
                    onTap: () =>
                        appNotifiers.selectedTab.value = ShellTabs.cart,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([
          appNotifiers.selectedTab,
          appNotifiers.cartCount,
          loyaltyController,
        ]),
        builder: (context, _) {
          return AppNavBar(
            index: appNotifiers.selectedTab.value,
            cartCount: appNotifiers.cartCount.value,
            questReady: loyaltyController.readyCount,
            onChanged: (value) => appNotifiers.selectedTab.value = value,
          );
        },
      ),
    );
  }
}
