import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/report_problem_link.dart';
import '../widgets/stadium_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const AppLogo(),
              const SizedBox(height: 28),
              Text(
                'Grind & Go HSE',
                style: textTheme.headlineLarge?.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 2),
              StadiumButton(
                label: 'Войти',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegistrationScreen(),
                    ),
                  );
                },
                child: Text(
                  'Регистрация',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const ReportProblemLink(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
