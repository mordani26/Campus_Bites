import 'package:flutter/material.dart';
import '../models/food_spot.dart';
import '../database/database_helper.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodSpot? foodSpot;

  const AddFoodScreen({super.key, this.foodSpot});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCuisine;
  bool _isFavorite = false;
  DateTime? _selectedDate;

  final List<String> _cuisines = [
    'American',
    'Mexican',
    'Italian',
    'Asian',
    'Fast Food',
  ];

  bool get _isEditMode => widget.foodSpot != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _nameController.text = widget.foodSpot!.name;
      _priceController.text = widget.foodSpot!.price.toString();
      _notesController.text = widget.foodSpot!.notes;
      _selectedCuisine = widget.foodSpot!.cuisine;
      _isFavorite = widget.foodSpot!.isFavorite;
      _selectedDate = DateTime.parse(widget.foodSpot!.dateVisited);
    }
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCuisine == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a cuisine')));
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick a date')));
      return;
    }

    final FoodSpot foodSpot = FoodSpot(
      id: _isEditMode ? widget.foodSpot!.id : null,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      cuisine: _selectedCuisine!,
      notes: _notesController.text.trim(),
      isFavorite: _isFavorite,
      dateVisited: _selectedDate!.toIso8601String(),
    );

    if (_isEditMode) {
      await DatabaseHelper.instance.updateFoodSpot(foodSpot);
    } else {
      await DatabaseHelper.instance.insertFoodSpot(foodSpot);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Food spot updated successfully'
              : 'Food spot saved successfully',
        ),
      ),
    );

    if (_isEditMode) {
      Navigator.pop(context, true);
      return;
    }

    _formKey.currentState!.reset();
    _nameController.clear();
    _priceController.clear();
    _notesController.clear();

    setState(() {
      _selectedCuisine = null;
      _isFavorite = false;
      _selectedDate = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayedDate = _selectedDate == null
        ? 'No date selected'
        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Food Spot' : 'Add Food Spot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Restaurant Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a restaurant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Average Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCuisine,
                decoration: const InputDecoration(labelText: 'Cuisine Type'),
                items: _cuisines.map((String cuisine) {
                  return DropdownMenuItem<String>(
                    value: cuisine,
                    child: Text(cuisine),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCuisine = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mark as Favorite'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(displayedDate)),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(
                  _isEditMode ? 'Update Food Spot' : 'Save Food Spot',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
