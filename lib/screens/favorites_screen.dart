import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'food_details_screen.dart';

// screen that shows only favorite food spots
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // list to store favorite spots
  List<FoodSpot> _favoriteSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // loads favorite spots when screen opens
    _loadFavorites();
  }

  // gets favorite food spots from the database
  Future<void> _loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavoriteFoodSpots();

    // updates the UI with favorite results
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
              // lets user pull down to refresh favorites
              onRefresh: _loadFavorites,
              child: _favoriteSpots.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        // message shown if there are no favorites
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
                            // favorite icon for each saved favorite item
                            leading: const Icon(Icons.favorite),
                            title: Text(spot.name),
                            subtitle: Text(
                              '${spot.cuisine} • \$${spot.price.toStringAsFixed(2)}',
                            ),
                            onTap: () async {
                              // opens details screen when user taps an item
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FoodDetailsScreen(foodSpot: spot),
                                ),
                              );

                              // reload favorites after coming back from details
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
