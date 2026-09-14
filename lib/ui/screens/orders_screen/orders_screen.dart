import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khaanado/app_util.dart';
import 'package:khaanado/constants/app_constants.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/route_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/order.dart';
import 'package:khaanado/service_locator.dart';
import 'package:khaanado/ui/custom_widgets/delivery_map.dart';
import 'package:khaanado/ui/custom_widgets/empty_state.dart';
import 'package:khaanado/ui/custom_widgets/primary_button.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    orderController.addListener(_refresh);
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted || !TickerMode.of(context)) return;
        if (orderController.liveOrder == null) return;
        orderController.refreshStatuses();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) orderController.refreshStatuses();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    orderController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _label(OrderStatus status) {
    return switch (status) {
      OrderStatus.placed => StringConstants.orderPlaced,
      OrderStatus.preparing => StringConstants.preparing,
      OrderStatus.onTheWay => StringConstants.onTheWay,
      OrderStatus.delivered => StringConstants.delivered,
      OrderStatus.cancelled => StringConstants.cancelled,
    };
  }

  Color _color(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => ColorConstants.success,
      OrderStatus.cancelled => ColorConstants.error,
      OrderStatus.onTheWay => ColorConstants.accent,
      OrderStatus.preparing => ColorConstants.warning,
      OrderStatus.placed => ColorConstants.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final orders = orderController.orders;
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: StringConstants.ordersEmptyTitle,
        body: StringConstants.ordersEmptyBody,
        actionLabel: StringConstants.browseMenu,
        onAction: () => appNotifiers.selectedTab.value = ShellTabs.home,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            StringConstants.ordersTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final live = order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled;
              return InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteConstants.tracking,
                  arguments: order.id,
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorConstants.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ColorConstants.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (live) ...[
                        DeliveryMapCard(
                          order: order,
                          height: 168,
                          compact: true,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Text(
                            order.id,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ColorConstants.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _label(order.status),
                            style: TextStyle(
                              color: _color(order.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${order.itemCount} items · ${AppUtil.rupees(order.total)}',
                        style: TextStyle(
                          color: ColorConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.address.oneLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorConstants.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  static const routeName = RouteConstants.tracking;

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    orderController.addListener(_refresh);
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => orderController.refreshStatuses(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) orderController.refreshStatuses();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    orderController.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _reorder(Order order) async {
    await cartController.replaceWith(order.lines);
    appNotifiers.cartCount.value = cartController.itemCount;
    if (!mounted) return;
    appNotifiers.selectedTab.value = ShellTabs.cart;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final order = orderController.byId(widget.orderId);
    if (order == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: StringConstants.genericError,
          body: '',
        ),
      );
    }

    const steps = [
      OrderStatus.placed,
      OrderStatus.preparing,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final current = steps.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(title: Text(order.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DeliveryMapCard(order: order, height: 240),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final done = current >= index;
            final label = switch (steps[index]) {
              OrderStatus.placed => StringConstants.orderPlaced,
              OrderStatus.preparing => StringConstants.preparing,
              OrderStatus.onTheWay => StringConstants.onTheWay,
              OrderStatus.delivered => StringConstants.delivered,
              OrderStatus.cancelled => StringConstants.cancelled,
            };
            return ListTile(
              leading: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? ColorConstants.success : ColorConstants.textMuted,
              ),
              title: Text(label),
            );
          }),
          const Divider(),
          Text(
            '${StringConstants.total}  ${AppUtil.rupees(order.total)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            order.address.oneLine,
            style: TextStyle(color: ColorConstants.textSecondary),
          ),
          const SizedBox(height: 20),
          ...order.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${line.item.name}  ×${line.quantity}')),
                  Text(AppUtil.rupees(line.lineTotal)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: StringConstants.reorder,
            onPressed: () => _reorder(order),
          ),
        ],
      ),
    );
  }
}
