import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
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
              Text(user?.name ?? 'Пользователь', style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user?.phone ?? '', style: textTheme.bodyMedium),
              if (user?.isBarista ?? false) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ],
              const Spacer(),
              SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
