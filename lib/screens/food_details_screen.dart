import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'add_food_screen.dart';

// screen that shows full details of a selected food spot
class FoodDetailsScreen extends StatelessWidget {
  final FoodSpot foodSpot;

  const FoodDetailsScreen({super.key, required this.foodSpot});

  // deletes a food spot after user confirms
  Future<void> _deleteFoodSpot(BuildContext context) async {
    // show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Food Spot'),
          content: const Text(
            'Are you sure you want to delete this food spot?',
          ),
          actions: [
            // cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            // confirm delete button
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

    // if user confirms, delete from database
    if (shouldDelete == true && foodSpot.id != null) {
      await DatabaseHelper.instance.deleteFoodSpot(foodSpot.id!);

      if (!context.mounted) return;

      // show confirmation message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Food spot deleted')));

      // go back and notify previous screen to refresh
      Navigator.pop(context, true);
    }
  }

  // opens edit screen for this food spot
  Future<void> _editFoodSpot(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(foodSpot: foodSpot),
      ),
    );

    // refresh previous screen after editing
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // converts favorite bool into readable text
    final String favoriteText = foodSpot.isFavorite ? 'Yes' : 'No';

    // formats date to show only yyyy-mm-dd
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
                // restaurant name
                Text(
                  foodSpot.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // basic info
                Text('Cuisine: ${foodSpot.cuisine}'),
                const SizedBox(height: 8),
                Text('Average Price: \$${foodSpot.price.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Favorite: $favoriteText'),
                const SizedBox(height: 8),
                Text('Date Visited: $formattedDate'),

                const SizedBox(height: 16),

                // notes section
                const Text('Notes:'),
                const SizedBox(height: 8),
                Text(
                  foodSpot.notes.isEmpty ? 'No notes added.' : foodSpot.notes,
                ),

                const SizedBox(height: 24),

                // button to edit the food spot
                ElevatedButton.icon(
                  onPressed: () => _editFoodSpot(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Food Spot'),
                ),

                const SizedBox(height: 12),

                // button to delete the food spot
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
