import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FoodSpot> _favoriteSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavoriteFoodSpots();

    setState(() {
      _favoriteSpots = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteSpots.isEmpty
          ? const Center(child: Text('No favorite food spots yet.'))
          : ListView.builder(
              itemCount: _favoriteSpots.length,
              itemBuilder: (context, index) {
                final spot = _favoriteSpots[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(spot.name),
                    subtitle: Text(
                      '${spot.cuisine} • \$${spot.price.toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
