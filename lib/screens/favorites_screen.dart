import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'food_details_screen.dart';

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
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: _favoriteSpots.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No favorite food spots yet.')),
                      ],
                    )
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
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FoodDetailsScreen(foodSpot: spot),
                                ),
                              );

                              if (result == true) {
                                _loadFavorites();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
