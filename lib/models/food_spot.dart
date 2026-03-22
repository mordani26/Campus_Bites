class FoodSpot {
  final int? id;
  final String name;
  final double price;
  final String cuisine;
  final String notes;
  final bool isFavorite;
  final String dateVisited;

  FoodSpot({
    this.id,
    required this.name,
    required this.price,
    required this.cuisine,
    required this.notes,
    required this.isFavorite,
    required this.dateVisited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cuisine': cuisine,
      'notes': notes,
      'isFavorite': isFavorite ? 1 : 0,
      'dateVisited': dateVisited,
    };
  }

  factory FoodSpot.fromMap(Map<String, dynamic> map) {
    return FoodSpot(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      cuisine: map['cuisine'],
      notes: map['notes'],
      isFavorite: map['isFavorite'] == 1,
      dateVisited: map['dateVisited'],
    );
  }
}
