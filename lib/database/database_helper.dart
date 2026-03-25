import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_spot.dart';

// this class handles all database operations
class DatabaseHelper {
  // creates a single instance of the database helper
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // gets the database, or creates it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('campus_bites.db');
    return _database!;
  }

  // initializes the database file
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFullPath = join(dbPath, filePath);

    return await openDatabase(dbFullPath, version: 1, onCreate: _createDB);
  }

  // creates the table when the database is first made
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_spots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        cuisine TEXT NOT NULL,
        notes TEXT,
        isFavorite INTEGER NOT NULL,
        dateVisited TEXT NOT NULL
      )
    ''');
  }

  // adds a new food spot to the database
  Future<int> insertFoodSpot(FoodSpot foodSpot) async {
    final db = await database;
    return await db.insert('food_spots', foodSpot.toMap());
  }

  // updates an existing food spot
  Future<int> updateFoodSpot(FoodSpot foodSpot) async {
    final db = await database;
    return await db.update(
      'food_spots',
      foodSpot.toMap(),
      where: 'id = ?',
      whereArgs: [foodSpot.id],
    );
  }

  // gets all food spots from the database
  Future<List<FoodSpot>> getAllFoodSpots() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_spots',
      orderBy: 'id DESC',
    );

    // converts database data into FoodSpot objects
    return List.generate(maps.length, (index) {
      return FoodSpot.fromMap(maps[index]);
    });
  }

  // gets only favorite food spots
  Future<List<FoodSpot>> getFavoriteFoodSpots() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_spots',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );

    // converts database data into FoodSpot objects
    return List.generate(maps.length, (index) {
      return FoodSpot.fromMap(maps[index]);
    });
  }

  // deletes a food spot by id
  Future<int> deleteFoodSpot(int id) async {
    final db = await database;
    return await db.delete('food_spots', where: 'id = ?', whereArgs: [id]);
  }
}
