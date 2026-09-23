import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/constants.dart';
import 'capture_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'varieties_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const _pages = [
    HomeScreen(),
    CaptureScreen(),
    HistoryScreen(),
    VarietiesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.emeraldLight,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppStrings.home),
          NavigationDestination(
              icon: Icon(Icons.center_focus_weak),
              selectedIcon: Icon(Icons.camera_alt),
              label: AppStrings.capture),
          NavigationDestination(
              icon: Icon(Icons.history), label: AppStrings.history),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: AppStrings.varieties),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.profile),
        ],
      ),
    );
  }
}
