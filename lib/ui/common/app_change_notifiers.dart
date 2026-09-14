import 'package:flutter/foundation.dart';

class AppChangeNotifiers {
  final selectedTab = ValueNotifier<int>(0);
  final showLoader = ValueNotifier<bool>(false);
  final cartCount = ValueNotifier<int>(0);

  void dispose() {
    selectedTab.dispose();
    showLoader.dispose();
    cartCount.dispose();
  }
}
