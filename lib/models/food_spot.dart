class FoodSpot {
  // basic fields for each food spot
  final int? id;
  final String name;
  final double price;
  final String cuisine;
  final String notes;
  final bool isFavorite;
  final String dateVisited;

  // constructor to create a FoodSpot object
  FoodSpot({
    this.id,
    required this.name,
    required this.price,
    required this.cuisine,
    required this.notes,
    required this.isFavorite,
    required this.dateVisited,
  });

  // converts FoodSpot object into a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cuisine': cuisine,
      'notes': notes,
      // stores boolean as 1 or 0 for SQLite
      'isFavorite': isFavorite ? 1 : 0,
      'dateVisited': dateVisited,
    };
  }

  // creates a FoodSpot object from database data
  factory FoodSpot.fromMap(Map<String, dynamic> map) {
    return FoodSpot(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      cuisine: map['cuisine'],
      notes: map['notes'],
      // converts 1/0 back to true/false
      isFavorite: map['isFavorite'] == 1,
      dateVisited: map['dateVisited'],
    );
  }
}
