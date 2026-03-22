import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';
import 'screens/home_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/budget_trackers_screen.dart';

class CampusBitesApp extends StatelessWidget {
  const CampusBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Bites',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AddFoodScreen(),
    FavoritesScreen(),
    BudgetTrackersScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
