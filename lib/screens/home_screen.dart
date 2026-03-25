import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';
import 'food_details_screen.dart';

// main screen that shows all food spots
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // full list from database
  List<FoodSpot> _foodSpots = [];

  // filtered list (used for search)
  List<FoodSpot> _filteredSpots = [];

  // suggested cheapest spots
  List<FoodSpot> _suggestedSpots = [];

  bool _isLoading = true;
  double _totalSpent = 0;

  // controller for search input
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // loads data when screen starts
    _loadFoodSpots();
  }

  // loads all food spots from database
  Future<void> _loadFoodSpots() async {
    final spots = await DatabaseHelper.instance.getAllFoodSpots();

    double total = 0;

    // calculates total spending
    for (final spot in spots) {
      total += spot.price;
    }

    // sort spots by price (cheapest first)
    final List<FoodSpot> sortedSpots = List.from(spots);
    sortedSpots.sort((a, b) => a.price.compareTo(b.price));

    // update UI
    setState(() {
      _foodSpots = spots;
      _filteredSpots = spots;
      _suggestedSpots = sortedSpots.take(3).toList(); // top 3 cheapest
      _totalSpent = total;
      _isLoading = false;
    });
  }

  // filters list based on search input
  void _filterSpots(String query) {
    final results = _foodSpots.where((spot) {
      final nameMatch = spot.name.toLowerCase().contains(query.toLowerCase());
      final cuisineMatch = spot.cuisine.toLowerCase().contains(
        query.toLowerCase(),
      );

      return nameMatch || cuisineMatch;
    }).toList();

    setState(() {
      _filteredSpots = results;
    });
  }

  // builds search bar UI
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search food spots...',
        prefixIcon: const Icon(Icons.search),

        // shows clear button when user types
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterSpots('');
                },
              )
            : null,
      ),
      onChanged: _filterSpots,
    );
  }

  // builds suggested (cheapest) section
  Widget _buildSuggestedSection() {
    // hide suggestions if searching
    if (_suggestedSpots.isEmpty || _searchController.text.isNotEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested Spots', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),

        // horizontal scroll for suggestions
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestedSpots.length,
            itemBuilder: (context, index) {
              final spot = _suggestedSpots[index];

              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: ListTile(
                    title: Text(spot.name),
                    subtitle: Text(
                      '${spot.cuisine}\n\$${spot.price.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // builds summary card with quick stats
  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Budget Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Saved Food Spots: ${_foodSpots.length}'),
            const SizedBox(height: 4),
            Text('Total Spent: \$${_totalSpent.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  // builds main list of food spots
  Widget _buildFoodList() {
    // message if no results
    if (_filteredSpots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No matching food spots found.'),
        ),
      );
    }

    return Column(
      children: _filteredSpots.map((spot) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            // icon changes if favorite
            leading: Icon(spot.isFavorite ? Icons.favorite : Icons.restaurant),
            title: Text(spot.name),
            subtitle: Text(
              '${spot.cuisine} • \$${spot.price.toStringAsFixed(2)}',
            ),
            onTap: () async {
              // opens details screen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailsScreen(foodSpot: spot),
                ),
              );

              // reload list after returning
              if (result == true) {
                _loadFoodSpots();
              }
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    // clean up controller
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Bites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // allows pull to refresh
              onRefresh: _loadFoodSpots,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildSuggestedSection(),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildFoodList(),
                ],
              ),
            ),
    );
  }
}
