import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/order_statuses.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class BaristaQueueScreen extends StatefulWidget {
  const BaristaQueueScreen({super.key});

  @override
  State<BaristaQueueScreen> createState() => _BaristaQueueScreenState();
}

class _BaristaQueueScreenState extends State<BaristaQueueScreen> {
  final _orderRepository = OrderRepository();

  List<Order>? _orders;
  String? _error;
  bool _loading = true;
  int? _updatingOrderId;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders = await _orderRepository.fetchBaristaQueue(token: token);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить очередь заказов.';
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(Order order, String status) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _updatingOrderId = order.id);

    try {
      await _orderRepository.updateOrderStatus(
        token: token,
        orderId: order.id,
        status: status,
      );
      await _loadQueue();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingOrderId = null);
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Заказы',
                      style: textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : _loadQueue,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadQueue,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final orders = _orders ?? [];

    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Нет активных заказов',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQueue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            isUpdating: _updatingOrderId == order.id,
            onTake: () => _updateStatus(order, OrderStatuses.inProgress),
            onReady: () => _updateStatus(order, OrderStatuses.ready),
            onIssue: () => _updateStatus(order, OrderStatuses.issued),
            onCancel: () => _updateStatus(order, OrderStatuses.cancelled),
          );
        },
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
    required this.onIssue,
    required this.onCancel,
  });

  final Order order;
  final bool isUpdating;
  final VoidCallback onTake;
  final VoidCallback onReady;
  final VoidCallback onIssue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  'Заказ #${order.id}',
                  style: textTheme.titleLarge,
                ),
              ),
              Text(
                order.status,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.coffee,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (order.clientName != null) ...[
            const SizedBox(height: 4),
            Text(
              order.clientName!,
              style: textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${item.productName} (${item.formattedSizeName}) × ${item.quantity}',
                style: textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '₽${order.totalPrice.toStringAsFixed(0)}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentDark,
            ),
          ),
          const SizedBox(height: 12),
          if (isUpdating)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order.status == OrderStatuses.created)
                  OutlinedButton(
                    onPressed: onTake,
                    child: const Text('Взять в работу'),
                  ),
                if (order.status == OrderStatuses.inProgress)
                  OutlinedButton(
                    onPressed: onReady,
                    child: const Text('Готов к выдаче'),
                  ),
                if (order.status == OrderStatuses.ready)
                  OutlinedButton(
                    onPressed: onIssue,
                    child: const Text('Выдан'),
                  ),
                if (order.status == OrderStatuses.created ||
                    order.status == OrderStatuses.inProgress)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Отменить заказ'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
