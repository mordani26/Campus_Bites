import 'package:flutter/material.dart';

// settings screen for app preferences
class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // card for dark mode toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Turn dark mode on or off for the app'),
                value: isDarkMode,
                // updates theme when user toggles switch
                onChanged: onDarkModeChanged,
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // card with app description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Campus Bites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),

                  // short explanation of what the app does
                  const Text(
                    'Campus Bites helps students save food spots, track spending, manage favorites, and stay within a weekly budget.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
