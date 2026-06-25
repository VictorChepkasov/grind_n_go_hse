import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/barista_shell.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme/theme.dart';

class GrindGoApp extends StatelessWidget {
  const GrindGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const WelcomeScreen();
    }

    if (user.isBarista) {
      return const BaristaShell();
    }

    return const MainShell();
  }
}
