import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';
import 'package:khaanado/ui/popups/base_popup.dart';

class FtuePopup {
  static Future<void> show(BuildContext context, {required VoidCallback onDone}) {
    return BasePopup.show(
      context: context,
      id: AppPopup.ftue,
      barrierDismissible: false,
      child: PopupCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, color: ColorConstants.accent, size: 42),
            const SizedBox(height: 12),
            Text(
              StringConstants.ftueTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorConstants.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const _FtueRow(index: '1', text: StringConstants.ftueBody1),
            const _FtueRow(index: '2', text: StringConstants.ftueBody2),
            const _FtueRow(index: '3', text: StringConstants.ftueBody3),
            const SizedBox(height: 20),
            PrimaryButton(
              label: StringConstants.gotIt,
              onPressed: () {
                BasePopup.close(context);
                onDone();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FtueRow extends StatelessWidget {
  const _FtueRow({required this.index, required this.text});

  final String index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: ColorConstants.accent,
            child: Text(
              index,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorConstants.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ColorConstants.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSuccessPopup {
  static Future<void> show(
    BuildContext context, {
    required String orderId,
    required VoidCallback onTrack,
  }) {
    return BasePopup.show(
      context: context,
      id: AppPopup.orderSuccess,
      barrierDismissible: false,
      child: PopupCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: ColorConstants.success, size: 52),
            const SizedBox(height: 12),
            Text(
              StringConstants.orderSuccessTitle,
              style: TextStyle(
                color: ColorConstants.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$orderId · ${StringConstants.orderSuccessBody}',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorConstants.textSecondary),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: StringConstants.trackOrder,
              onPressed: () {
                BasePopup.close(context);
                onTrack();
              },
            ),
          ],
        ),
      ),
    );
  }
}
