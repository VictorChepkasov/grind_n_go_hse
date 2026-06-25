import 'package:flutter/material.dart';

import '../core/support_form.dart';
import '../theme/app_colors.dart';
import '../widgets/stadium_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _openForm(BuildContext context) async {
    final opened = await openSupportForm();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось открыть форму. Проверьте подключение к интернету.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Техническая поддержка Grind & Go HSE'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Связь с разработчиками',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Если что-то пошло не так, опишите проблему в Google-форме. '
                'Если вопрос связан с аккаунтом, укажите номер телефона, '
                'к которому привязан Grind & Go HSE.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              StadiumButton(
                label: 'Открыть форму',
                width: double.infinity,
                backgroundColor: AppColors.accentDark,
                foregroundColor: AppColors.textOnPrimary,
                onPressed: () => _openForm(context),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.coffee,
                    side: const BorderSide(color: AppColors.coffee),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Назад'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
