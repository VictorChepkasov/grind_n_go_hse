import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../providers/navigation_provider.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = <Widget>[
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: nav.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.currentIndex,
        onTap: nav.selectTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart_rounded),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
