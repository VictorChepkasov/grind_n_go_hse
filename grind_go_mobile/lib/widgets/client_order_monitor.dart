import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_messenger.dart';
import '../core/order_config.dart';
import '../core/order_statuses.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';

class ClientOrderMonitor extends StatefulWidget {
  const ClientOrderMonitor({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ClientOrderMonitor> createState() => _ClientOrderMonitorState();
}

class _ClientOrderMonitorState extends State<ClientOrderMonitor> {
  final _orderRepository = OrderRepository();
  Timer? _pollTimer;
  final Map<int, String> _knownStatuses = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkOrders());
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOrders());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkOrders() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || (auth.user?.isBarista ?? false)) return;

    try {
      final orders = await _orderRepository.fetchMyOrders(token: token);
      if (!mounted) return;

      if (!_initialized) {
        _knownStatuses
          ..clear()
          ..addEntries(orders.map((order) => MapEntry(order.id, order.status)));
        _initialized = true;
        return;
      }

      var profileNeedsRefresh = false;

      for (final order in orders) {
        final previousStatus = _knownStatuses[order.id];
        if (previousStatus == null) {
          _knownStatuses[order.id] = order.status;
          continue;
        }

        if (previousStatus != order.status) {
          _notifyStatusChange(order.id, order.status);
          _knownStatuses[order.id] = order.status;
          profileNeedsRefresh = true;
        }
      }

      final currentIds = orders.map((order) => order.id).toSet();
      final disappearedIds = _knownStatuses.keys
          .where((id) => !currentIds.contains(id))
          .toList();

      for (final orderId in disappearedIds) {
        final previousStatus = _knownStatuses.remove(orderId);
        final order = await _orderRepository.fetchOrderById(
          token: token,
          orderId: orderId,
        );

        if (!mounted) return;

        if (order == null || order.status == previousStatus) continue;

        _notifyStatusChange(orderId, order.status);
        profileNeedsRefresh = true;
      }

      if (profileNeedsRefresh && mounted) {
        context.read<NavigationProvider>().refreshProfileOrders();
      }
    } catch (_) {
      // Polling errors are ignored; profile screen shows errors on manual refresh.
    }
  }

  void _notifyStatusChange(int orderId, String status) {
    final message = orderStatusNotificationMessage(orderId, status);
    if (message == null) return;

    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _notificationColor(status),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color? _notificationColor(String status) {
    switch (status) {
      case OrderStatuses.cancelled:
        return AppColors.error;
      case OrderStatuses.ready:
        return AppColors.success;
      case OrderStatuses.inProgress:
        return AppColors.coffee;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
