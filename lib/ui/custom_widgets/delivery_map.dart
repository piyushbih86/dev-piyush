import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/order.dart';

class DeliveryMapCard extends StatefulWidget {
  const DeliveryMapCard({
    super.key,
    required this.order,
    this.height = 210,
    this.compact = false,
    this.onTap,
  });

  final Order order;
  final double height;
  final bool compact;
  final VoidCallback? onTap;

  @override
  State<DeliveryMapCard> createState() => _DeliveryMapCardState();
}

class _DeliveryMapCardState extends State<DeliveryMapCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final progress = deliveryMapProgress(order);
    final eta = deliveryEtaLabel(order);
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MapPainter(
                    progress: progress,
                    pulse: _pulse.value,
                    dark: ColorConstants.isDark,
                    delivered: order.status == OrderStatus.delivered,
                  ),
                );
              },
            ),
            Positioned(
              left: 12,
              top: 12,
              child: _MapChip(
                icon: Icons.access_time_rounded,
                label: eta,
              ),
            ),
            if (!widget.compact)
              Positioned(
                right: 12,
                top: 12,
                child: _MapChip(
                  icon: Icons.delivery_dining_rounded,
                  label: _statusLabel(order.status),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.card.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: ColorConstants.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.address.isComplete
                            ? order.address.oneLine
                            : StringConstants.deliveringTo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.onTap == null) return child;
    return GestureDetector(onTap: widget.onTap, child: child);
  }

  String _statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => StringConstants.orderPlaced,
      OrderStatus.preparing => StringConstants.preparing,
      OrderStatus.onTheWay => StringConstants.onTheWay,
      OrderStatus.delivered => StringConstants.delivered,
      OrderStatus.cancelled => StringConstants.cancelled,
    };
  }
}

double deliveryMapProgress(Order order, {DateTime? now}) {
  if (order.status == OrderStatus.delivered) return 1;
  if (order.status == OrderStatus.cancelled) return 0;
  final elapsed =
      (now ?? DateTime.now()).difference(order.placedAt).inMilliseconds /
          1000.0;
  final t = (elapsed / AppConstants.deliveredAfterSec).clamp(0.0, 0.96);
  if (order.status == OrderStatus.placed) {
    return (0.06 + t * 0.08).clamp(0.06, 0.14);
  }
  if (order.status == OrderStatus.preparing) {
    return (0.14 + t * 0.18).clamp(0.14, 0.36);
  }
  return (0.36 + t * 0.58).clamp(0.36, 0.92);
}

String deliveryEtaLabel(Order order, {DateTime? now}) {
  if (order.status == OrderStatus.delivered) return 'Arrived';
  if (order.status == OrderStatus.cancelled) return StringConstants.cancelled;
  final left = AppConstants.deliveredAfterSec -
      (now ?? DateTime.now()).difference(order.placedAt).inSeconds;
  final mins = ((left / AppConstants.deliveredAfterSec) * 22)
      .clamp(1, 22)
      .round();
  return '$mins mins';
}

class _MapChip extends StatelessWidget {
  const _MapChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorConstants.card.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorConstants.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.progress,
    required this.pulse,
    required this.dark,
    required this.delivered,
  });

  final double progress;
  final double pulse;
  final bool dark;
  final bool delivered;

  @override
  void paint(Canvas canvas, Size size) {
    final land = dark ? const Color(0xff1c2430) : const Color(0xffe8eee4);
    final block = dark ? const Color(0xff2a3344) : const Color(0xffd5ddd0);
    final park = dark ? const Color(0xff24362c) : const Color(0xffc5dcb8);
    final road = dark ? const Color(0xff3d4758) : const Color(0xfff4f1ea);
    final roadEdge = dark ? const Color(0xff586274) : const Color(0xffcfc8bb);

    canvas.drawRect(Offset.zero & size, Paint()..color = land);

    final rand = math.Random(7);
    for (var i = 0; i < 18; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 28.0 + rand.nextDouble() * 46;
      final h = 22.0 + rand.nextDouble() * 38;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(4),
        ),
        Paint()..color = i % 5 == 0 ? park : block,
      );
    }

    final start = Offset(size.width * 0.16, size.height * 0.72);
    final mid = Offset(size.width * 0.48, size.height * 0.28);
    final end = Offset(size.width * 0.84, size.height * 0.38);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = roadEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = road
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    final dash = Paint()
      ..color = dark ? const Color(0x66ffffff) : const Color(0x99ffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final extract = metric.extractPath(d, math.min(d + 8, metric.length));
        canvas.drawPath(extract, dash);
        d += 16;
      }
    }

    _pin(canvas, start, ColorConstants.accent, Icons.storefront_rounded);
    _pin(canvas, end, const Color(0xff3b82f6), Icons.home_rounded);

    final courier = _pointOn(path, progress);
    final ring = 10.0 + pulse * 10;
    canvas.drawCircle(
      courier,
      ring,
      Paint()
        ..color = ColorConstants.accent.withValues(alpha: 0.18 * (1 - pulse)),
    );
    canvas.drawCircle(courier, 13, Paint()..color = Colors.white);
    canvas.drawCircle(courier, 11, Paint()..color = ColorConstants.accent);

    final icon = delivered
        ? Icons.check_rounded
        : Icons.delivery_dining_rounded;
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 14,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      courier - Offset(painter.width / 2, painter.height / 2),
    );
  }

  Offset _pointOn(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset.zero;
    final metric = metrics.first;
    return metric.getTangentForOffset(metric.length * t.clamp(0, 1))?.position ??
        Offset.zero;
  }

  void _pin(Canvas canvas, Offset at, Color color, IconData icon) {
    canvas.drawCircle(
      at,
      16,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(at, 12, Paint()..color = color);
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 12,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      at - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.dark != dark ||
        oldDelegate.delivered != delivered;
  }
}
