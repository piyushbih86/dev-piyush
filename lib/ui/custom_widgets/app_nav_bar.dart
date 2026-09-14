import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.index,
    required this.cartCount,
    required this.questReady,
    required this.onChanged,
  });

  final int index;
  final int cartCount;
  final int questReady;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      backgroundColor: ColorConstants.surface,
      indicatorColor: ColorConstants.accentSoft,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: StringConstants.navHome,
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: questReady > 0,
            label: Text('$questReady'),
            backgroundColor: ColorConstants.accent,
            textColor: Colors.white,
            child: const Icon(Icons.card_giftcard_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: questReady > 0,
            label: Text('$questReady'),
            backgroundColor: ColorConstants.accent,
            textColor: Colors.white,
            child: const Icon(Icons.card_giftcard),
          ),
          label: StringConstants.navQuests,
        ),
        const NavigationDestination(
          icon: Icon(Icons.delivery_dining_outlined),
          selectedIcon: Icon(Icons.delivery_dining_rounded),
          label: StringConstants.navOrders,
        ),
        NavigationDestination(
          icon: _CartIcon(count: cartCount, selected: false),
          selectedIcon: _CartIcon(count: cartCount, selected: true),
          label: StringConstants.navCart,
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: StringConstants.navProfile,
        ),
      ],
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: ColorConstants.accent,
      child: Icon(
        selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
      ),
    );
  }
}
