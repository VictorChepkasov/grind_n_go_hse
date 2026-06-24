import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/order_statuses.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';

class BaristaQueueScreen extends StatefulWidget {
  const BaristaQueueScreen({super.key});

  @override
  State<BaristaQueueScreen> createState() => _BaristaQueueScreenState();
}

class _BaristaQueueScreenState extends State<BaristaQueueScreen> {
  Future<List<Order>>? _ordersFuture;
  final Set<int> _updatingOrders = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ordersFuture ??= _loadOrders();
  }

  Future<List<Order>> _loadOrders() {
    return context.read<OrderRepository>().fetchBaristaQueue();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = _loadOrders();
    });
  }

  Future<void> _updateStatus(Order order, String newStatus) async {
    setState(() => _updatingOrders.add(order.orderId));

    try {
      await context.read<OrderRepository>().updateOrderStatus(
            order.orderId,
            newStatus,
          );
      _refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Заказ №${order.orderId}: ${OrderStatuses.label(newStatus)}',
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обновить статус заказа')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingOrders.remove(order.orderId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Заказы',
                      style: textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Обновить',
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !(snapshot.hasData && snapshot.data!.isNotEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _QueueError(
                      message: snapshot.error.toString(),
                      onRetry: _refresh,
                    );
                  }

                  final orders = snapshot.data ?? [];
                  if (orders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 64,
                              color: AppColors.coffeeLight,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет активных заказов',
                              style: textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Новые заказы появятся здесь автоматически.',
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _ordersFuture = _loadOrders();
                      });
                      await _ordersFuture;
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          order: order,
                          isUpdating: _updatingOrders.contains(order.orderId),
                          onTake: () =>
                              _updateStatus(order, OrderStatuses.inProgress),
                          onReady: () =>
                              _updateStatus(order, OrderStatuses.ready),
                          onCancel: () =>
                              _updateStatus(order, OrderStatuses.cancelled),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueError extends StatelessWidget {
  const _QueueError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Не удалось загрузить заказы',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isUpdating,
    required this.onTake,
    required this.onReady,
    required this.onCancel,
  });

  final Order order;
  final bool isUpdating;
  final VoidCallback onTake;
  final VoidCallback onReady;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Заказ №${order.orderId}',
                  style: textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  OrderStatuses.label(order.status),
                  style: textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.customerName ?? 'Клиент'} · ${_formatTime(order.createdAt)}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} (${item.sizeName})',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    '×${item.quantity}',
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Итого: ₽${order.totalPrice.toStringAsFixed(0)}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentDark,
            ),
          ),
          if (_hasActions(order.status)) ...[
            const SizedBox(height: 14),
            if (isUpdating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _OrderActions(
                status: order.status,
                onTake: onTake,
                onReady: onReady,
                onCancel: onCancel,
              ),
          ],
        ],
      ),
    );
  }

  bool _hasActions(String status) =>
      status == OrderStatuses.created || status == OrderStatuses.inProgress;

  Color _statusColor(String status) => switch (status) {
        OrderStatuses.created => AppColors.accentDark,
        OrderStatuses.inProgress => AppColors.coffee,
        OrderStatuses.ready => AppColors.success,
        OrderStatuses.cancelled => AppColors.error,
        _ => AppColors.textMuted,
      };

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.status,
    required this.onTake,
    required this.onReady,
    required this.onCancel,
  });

  final String status;
  final VoidCallback onTake;
  final VoidCallback onReady;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (status == OrderStatuses.created)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTake,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coffee,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Взять в работу'),
            ),
          ),
        if (status == OrderStatuses.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReady,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Готов к выдаче'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Отменить заказ'),
        ),
      ],
    );
  }
}
