import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'add_food_screen.dart';

class FoodDetailsScreen extends StatelessWidget {
  final FoodSpot foodSpot;

  const FoodDetailsScreen({super.key, required this.foodSpot});

  Future<void> _deleteFoodSpot(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Food Spot'),
          content: const Text(
            'Are you sure you want to delete this food spot?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && foodSpot.id != null) {
      await DatabaseHelper.instance.deleteFoodSpot(foodSpot.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Food spot deleted')));

      Navigator.pop(context, true);
    }
  }

  Future<void> _editFoodSpot(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(foodSpot: foodSpot),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String favoriteText = foodSpot.isFavorite ? 'Yes' : 'No';
    final String formattedDate = foodSpot.dateVisited.split('T')[0];

    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  foodSpot.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text('Cuisine: ${foodSpot.cuisine}'),
                const SizedBox(height: 8),
                Text('Average Price: \$${foodSpot.price.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Favorite: $favoriteText'),
                const SizedBox(height: 8),
                Text('Date Visited: $formattedDate'),
                const SizedBox(height: 16),
                const Text('Notes:'),
                const SizedBox(height: 8),
                Text(
                  foodSpot.notes.isEmpty ? 'No notes added.' : foodSpot.notes,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _editFoodSpot(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Food Spot'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _deleteFoodSpot(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Food Spot'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
