import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/order_config.dart';
import '../core/order_statuses.dart';
import '../data/order_repository.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _orderRepository = OrderRepository();
  Timer? _pollTimer;

  List<Order>? _orders;
  String? _error;
  bool _loading = true;
  int _lastRefreshToken = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavigationProvider>().addListener(_onNavigationChanged);
      _loadOrders();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (context.read<NavigationProvider>().currentIndex == 2) {
        _loadOrders(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    context.read<NavigationProvider>().removeListener(_onNavigationChanged);
    super.dispose();
  }

  void _onNavigationChanged() {
    final refreshToken = context.read<NavigationProvider>().profileRefreshToken;
    if (refreshToken != _lastRefreshToken) {
      _lastRefreshToken = refreshToken;
      _loadOrders();
    }
  }

  Future<void> _loadOrders({bool silent = false}) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final orders = await _orderRepository.fetchMyOrders(token: token);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _error = null;
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
        _error = 'Не удалось загрузить заказы.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.watch<AuthProvider>().user;
    final isBarista = user?.isBarista ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.coffee,
                      child: Text(
                        (user?.name.isNotEmpty ?? false)
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Пользователь',
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.phone ?? '',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (isBarista) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coffee.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Бариста',
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.coffee,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (!isBarista) ...[
                      const SizedBox(height: 28),
                      Text('Мои заказы', style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _buildOrdersSection(textTheme),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coffee,
                    side: const BorderSide(color: AppColors.coffee),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Выйти'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection(TextTheme textTheme) {
    if (_loading && (_orders == null || _orders!.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadOrders,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    final orders = _orders ?? [];

    if (orders.isEmpty) {
      return Text(
        'Активных заказов пока нет',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: [
        for (final order in orders) ...[
          _ClientOrderCard(order: order),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ClientOrderCard extends StatelessWidget {
  const _ClientOrderCard({required this.order});

  final Order order;

  bool get _showPrepTime =>
      order.status == OrderStatuses.created ||
      order.status == OrderStatuses.inProgress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hint = orderStatusHint(order.status);

    return Container(
      width: double.infinity,
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
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              hint,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_showPrepTime) ...[
            const SizedBox(height: 8),
            Text(
              'Примерное время: ~$estimatedOrderPrepMinutes мин',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.accentDark,
                fontWeight: FontWeight.w600,
              ),
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
          const SizedBox(height: 8),
          Text(
            '₽${order.totalPrice.toStringAsFixed(0)}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.accentDark,
            ),
          ),
        ],
      ),
    );
  }
}
