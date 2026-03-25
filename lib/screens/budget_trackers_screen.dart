import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/food_spot.dart';

// screen that shows budget tracking and spending info
class BudgetTrackersScreen extends StatefulWidget {
  const BudgetTrackersScreen({super.key});

  @override
  State<BudgetTrackersScreen> createState() => _BudgetTrackersScreenState();
}

class _BudgetTrackersScreenState extends State<BudgetTrackersScreen> {
  // list of food spots from database
  List<FoodSpot> _foodSpots = [];
  bool _isLoading = true;

  // variables to store calculations
  double _totalSpent = 0;
  double _weeklySpent = 0;
  int _mealCount = 0;
  double _weeklyBudget = 0;

  @override
  void initState() {
    super.initState();
    // load data when screen starts
    _loadBudgetData();
  }

  // loads all food spots and calculates totals
  Future<void> _loadBudgetData() async {
    final spots = await DatabaseHelper.instance.getAllFoodSpots();
    final prefs = await SharedPreferences.getInstance();

    double total = 0;
    double weekly = 0;

    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    // loop through all food spots
    for (final spot in spots) {
      total += spot.price;

      final DateTime visitedDate = DateTime.parse(spot.dateVisited);

      // check if the meal was within the last 7 days
      if (visitedDate.isAfter(sevenDaysAgo) ||
          visitedDate.isAtSameMomentAs(sevenDaysAgo)) {
        weekly += spot.price;
      }
    }

    // update UI with calculated values
    setState(() {
      _foodSpots = spots;
      _totalSpent = total;
      _weeklySpent = weekly;
      _mealCount = spots.length;
      _weeklyBudget = prefs.getDouble('weekly_budget') ?? 0;
      _isLoading = false;
    });
  }

  // shows dialog to set or update weekly budget
  Future<void> _showBudgetDialog() async {
    final TextEditingController budgetController = TextEditingController(
      text: _weeklyBudget > 0 ? _weeklyBudget.toStringAsFixed(2) : '',
    );

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Weekly Budget'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Weekly Budget',
                prefixText: '\$',
              ),
              // validates input before saving
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a budget';
                }

                final parsedValue = double.tryParse(value.trim());
                if (parsedValue == null || parsedValue <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),
          ),
          actions: [
            // cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            // save button
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    double.parse(budgetController.text.trim()),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // save budget in shared preferences
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('weekly_budget', result);

      setState(() {
        _weeklyBudget = result;
      });

      if (!mounted) return;

      // show confirmation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Weekly budget saved')));
    }
  }

  // formats date to show only yyyy-mm-dd
  String _formatDate(String rawDate) {
    final DateTime date = DateTime.parse(rawDate);
    return date.toString().split(' ')[0];
  }

  // builds warning message if user is close to or over budget
  Widget _buildBudgetWarningCard() {
    if (_weeklyBudget <= 0) {
      return const SizedBox();
    }

    final double remainingAmount = _weeklyBudget - _weeklySpent;

    // user is over budget
    if (_weeklySpent > _weeklyBudget) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You have passed your weekly budget by \$${(_weeklySpent - _weeklyBudget).toStringAsFixed(2)}.',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // user is close to budget (within $20)
    if (remainingAmount <= 20) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Warning: You are only \$${remainingAmount.toStringAsFixed(2)} away from your weekly budget.',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  // builds summary card with totals and budget info
  Widget _buildBudgetSummaryCard(BuildContext context) {
    final double remainingAmount = _weeklyBudget > 0
        ? (_weeklyBudget - _weeklySpent)
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Total Spent: \$${_totalSpent.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Spent in Last 7 Days: \$${_weeklySpent.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Meals Recorded: $_mealCount'),
            const SizedBox(height: 8),
            Text(
              _weeklyBudget > 0
                  ? 'Weekly Budget: \$${_weeklyBudget.toStringAsFixed(2)}'
                  : 'Weekly Budget: Not set',
            ),
            if (_weeklyBudget > 0) ...[
              const SizedBox(height: 8),
              Text(
                remainingAmount >= 0
                    ? 'Remaining Budget: \$${remainingAmount.toStringAsFixed(2)}'
                    : 'Over Budget By: \$${remainingAmount.abs().toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: 16),
            // button to set or update budget
            ElevatedButton.icon(
              onPressed: _showBudgetDialog,
              icon: const Icon(Icons.edit),
              label: Text(
                _weeklyBudget > 0
                    ? 'Update Weekly Budget'
                    : 'Set Weekly Budget',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // shows all recorded meals
  Widget _buildMealRecordsSection(BuildContext context) {
    if (_foodSpots.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No meal records yet.'),
        ),
      );
    }

    return Column(
      children: _foodSpots.map((spot) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            // shows favorite icon if marked
            leading: Icon(spot.isFavorite ? Icons.favorite : Icons.restaurant),
            title: Text(spot.name),
            subtitle: Text(
              '${spot.cuisine} • ${_formatDate(spot.dateVisited)}',
            ),
            trailing: Text('\$${spot.price.toStringAsFixed(2)}'),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // allows pull to refresh
              onRefresh: _loadBudgetData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBudgetSummaryCard(context),
                  const SizedBox(height: 16),
                  _buildBudgetWarningCard(),
                  if (_weeklyBudget > 0) const SizedBox(height: 16),
                  Text(
                    'Meal Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildMealRecordsSection(context),
                ],
              ),
            ),
    );
  }
}
