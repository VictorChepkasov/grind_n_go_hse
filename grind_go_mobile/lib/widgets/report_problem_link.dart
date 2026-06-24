import 'package:flutter/material.dart';

import '../screens/support_screen.dart';
import '../theme/app_colors.dart';

class ReportProblemLink extends StatelessWidget {
  const ReportProblemLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const SupportScreen(),
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
