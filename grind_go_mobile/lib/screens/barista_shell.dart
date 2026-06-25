import 'package:flutter/material.dart';

import 'barista_menu_screen.dart';
import 'barista_queue_screen.dart';
import 'profile_screen.dart';

class BaristaShell extends StatefulWidget {
  const BaristaShell({super.key});

  @override
  State<BaristaShell> createState() => _BaristaShellState();
}

class _BaristaShellState extends State<BaristaShell> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    BaristaMenuScreen(),
    BaristaQueueScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Меню',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Заказы',
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
