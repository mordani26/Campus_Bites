import 'package:flutter/material.dart';

class BudgetTrackersScreen extends StatelessWidget {
  const BudgetTrackersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: const Center(child: Text('Budget Tracker Screen')),
    );
  }
}
