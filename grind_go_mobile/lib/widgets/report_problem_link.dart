import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ReportProblemLink extends StatelessWidget {
  const ReportProblemLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Форма обратной связи будет добавлена позже'),
          ),
        );
      },
      child: Text(
        'Сообщить о проблеме',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
