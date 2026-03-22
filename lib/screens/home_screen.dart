import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'food_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodSpot> _foodSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodSpots();
  }

  Future<void> _loadFoodSpots() async {
    final spots = await DatabaseHelper.instance.getAllFoodSpots();

    setState(() {
      _foodSpots = spots;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Bites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foodSpots.isEmpty
          ? const Center(child: Text('No food spots added yet.'))
          : ListView.builder(
              itemCount: _foodSpots.length,
              itemBuilder: (context, index) {
                final spot = _foodSpots[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Icon(
                      spot.isFavorite ? Icons.favorite : Icons.restaurant,
                    ),
                    title: Text(spot.name),
                    subtitle: Text(
                      '${spot.cuisine} • \$${spot.price.toStringAsFixed(2)}',
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodDetailsScreen(foodSpot: spot),
                        ),
                      );

                      if (result == true) {
                        _loadFoodSpots();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
