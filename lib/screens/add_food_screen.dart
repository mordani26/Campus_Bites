import 'package:flutter/material.dart';
import '../models/food_spot.dart';
import '../database/database_helper.dart';

// screen for adding or editing a food spot
class AddFoodScreen extends StatefulWidget {
  final FoodSpot? foodSpot;

  const AddFoodScreen({super.key, this.foodSpot});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // key to manage form validation
  final _formKey = GlobalKey<FormState>();

  // controllers to get input from text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCuisine;
  bool _isFavorite = false;
  DateTime? _selectedDate;

  // list of cuisines for dropdown
  final List<String> _cuisines = [
    'American',
    'Mexican',
    'Italian',
    'Asian',
    'Fast Food',
  ];

  // checks if we are editing or adding a new item
  bool get _isEditMode => widget.foodSpot != null;

  @override
  void initState() {
    super.initState();

    // if editing, fill fields with existing data
    if (_isEditMode) {
      _nameController.text = widget.foodSpot!.name;
      _priceController.text = widget.foodSpot!.price.toString();
      _notesController.text = widget.foodSpot!.notes;
      _selectedCuisine = widget.foodSpot!.cuisine;
      _isFavorite = widget.foodSpot!.isFavorite;
      _selectedDate = DateTime.parse(widget.foodSpot!.dateVisited);
    }
  }

  // opens date picker for selecting visit date
  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // update UI with selected date
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // saves the form data into the database
  Future<void> _saveForm() async {
    // check if form inputs are valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // check if cuisine is selected
    if (_selectedCuisine == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a cuisine')));
      return;
    }

    // check if date is selected
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick a date')));
      return;
    }

    // create a FoodSpot object from user input
    final FoodSpot foodSpot = FoodSpot(
      id: _isEditMode ? widget.foodSpot!.id : null,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      cuisine: _selectedCuisine!,
      notes: _notesController.text.trim(),
      isFavorite: _isFavorite,
      dateVisited: _selectedDate!.toIso8601String(),
    );

    // update or insert depending on mode
    if (_isEditMode) {
      await DatabaseHelper.instance.updateFoodSpot(foodSpot);
    } else {
      await DatabaseHelper.instance.insertFoodSpot(foodSpot);
    }

    if (!mounted) return;

    // show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode
              ? 'Food spot updated successfully'
              : 'Food spot saved successfully',
        ),
      ),
    );

    // go back if editing
    if (_isEditMode) {
      Navigator.pop(context, true);
      return;
    }

    // reset form after saving
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
    // dispose controllers to avoid memory leaks
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // shows selected date or default message
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
              // input for restaurant name
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

              // input for price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
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

              // dropdown for cuisine selection
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

              // notes input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // toggle for favorite
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

              // date picker section
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

              // save or update button
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
