import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/service_locator.dart';

class DailyResetTicker extends StatefulWidget {
  const DailyResetTicker({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  State<DailyResetTicker> createState() => _DailyResetTickerState();
}

class _DailyResetTickerState extends State<DailyResetTicker> {
  Timer? _timer;
  late String _label;

  @override
  void initState() {
    super.initState();
    _label = _compute();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      loyaltyController.tickDay();
      if (!mounted) return;
      setState(() => _label = _compute());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _compute() {
    if (widget.compact) return loyaltyController.dailyResetShort();
    return loyaltyController.dailyResetLabel();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.compact ? 'Resets $_label' : _label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: ColorConstants.textMuted,
        fontSize: widget.compact ? 11 : 12,
        fontWeight: FontWeight.w600,
      ),
    );
    return Row(
      mainAxisSize: widget.compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: widget.compact ? 12 : 14,
          color: ColorConstants.textMuted,
        ),
        const SizedBox(width: 4),
        if (widget.compact) text else Expanded(child: text),
      ],
    );
  }
}
