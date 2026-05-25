import 'package:flutter/material.dart';

import 'theme/theme.dart';

void main() {
  runApp(const GrindGoApp());
}

class GrindGoApp extends StatelessWidget {
  const GrindGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grind & Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _ThemePreviewScreen(),
    );
  }
}

/// Временный экран для проверки темы. Заменим на WelcomeScreen на следующем шаге.
class _ThemePreviewScreen extends StatelessWidget {
  const _ThemePreviewScreen();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Grind & Go')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Grind&GO HSE', style: textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Тема подключена — кофейная палитра',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Войти'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Регистрация'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
