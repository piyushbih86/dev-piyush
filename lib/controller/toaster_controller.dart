import 'package:flutter/material.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/ui/custom_widgets/custom_toaster.dart';

enum ToasterKind { info, success, error }

class ToasterController {
  OverlayEntry? _entry;

  void show(
    BuildContext context,
    String message, {
    ToasterKind kind = ToasterKind.info,
  }) {
    hide();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final durationMs = AppUtil.toasterDurationMs(message);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => CustomToaster(
        message: message,
        kind: kind,
        durationMs: durationMs,
        onDone: hide,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}
