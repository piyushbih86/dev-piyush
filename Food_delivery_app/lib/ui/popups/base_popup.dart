import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';

enum AppPopup { none, ftue, orderSuccess }

class BasePopup {
  static const openMs = 280;
  static const closeMs = 180;
  static final List<AppPopup> openPopups = [];

  static Future<T?> show<T>({
    required BuildContext context,
    required AppPopup id,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    openPopups.add(id);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: id.name,
      barrierColor: ColorConstants.overlay,
      transitionDuration: const Duration(milliseconds: openMs),
      pageBuilder: (_, __, ___) => child,
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    ).whenComplete(() {
      openPopups.remove(id);
    });
  }

  static void close(BuildContext context) {
    Navigator.of(context, rootNavigator: true).maybePop();
  }
}

class PopupCard extends StatelessWidget {
  const PopupCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: ColorConstants.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorConstants.cardBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
