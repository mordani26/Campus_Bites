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
  List<FoodSpot> _suggestedSpots = [];

  bool _isLoading = true;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadFoodSpots();
  }

  Future<void> _loadFoodSpots() async {
    final spots = await DatabaseHelper.instance.getAllFoodSpots();

    double total = 0;
    for (final spot in spots) {
      total += spot.price;
    }

    final List<FoodSpot> sortedSpots = List.from(spots);
    sortedSpots.sort((a, b) {
      return a.price.compareTo(b.price);
    });

    final List<FoodSpot> cheapestSpots = sortedSpots.take(3).toList();

    setState(() {
      _foodSpots = spots;
      _suggestedSpots = cheapestSpots;
      _totalSpent = total;
      _isLoading = false;
    });
  }

  Widget _buildSuggestedSection() {
    if (_suggestedSpots.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Spots (Best Deals)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            spot.isFavorite
                                ? Icons.favorite
                                : Icons.local_offer_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            spot.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            spot.cuisine,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const Spacer(),
                          Text(
                            '\$${spot.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSpotCard(FoodSpot spot) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            spot.isFavorite ? Icons.favorite : Icons.restaurant,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          spot.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${spot.cuisine} • \$${spot.price.toStringAsFixed(2)}'),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailsScreen(foodSpot: spot),
            ),
          );

          if (result == true) {
            _loadFoodSpots();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Bites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFoodSpots,
              child: _foodSpots.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text(
                            'No food spots added yet.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSuggestedSection(),
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        Text(
                          'Your Saved Spots',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        ..._foodSpots.map(_buildFoodSpotCard),
                      ],
                    ),
            ),
    );
  }
}
