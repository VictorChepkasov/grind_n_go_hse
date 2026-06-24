import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/api_client.dart';
import 'data/auth_repository.dart';
import 'data/menu_repository.dart';
import 'data/order_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/barista_shell.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme/theme.dart';

class GrindGoApp extends StatelessWidget {
  const GrindGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final apiClient = ApiClient(tokenProvider: () => authRepository.token);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        Provider(create: (_) => MenuRepository(apiClient: apiClient)),
        Provider(create: (_) => OrderRepository(apiClient: apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Grind & Go',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    if (isAuthenticated) {
      final user = context.watch<AuthProvider>().user;
      if (user?.isBarista ?? false) {
        return const BaristaShell();
      }
      return const MainShell();
    }

    return const WelcomeScreen();
  }
}
