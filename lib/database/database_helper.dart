import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_spot.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('campus_bites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFullPath = join(dbPath, filePath);

    return await openDatabase(dbFullPath, version: 1, onCreate: _createDB);
  }

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

  Future<int> insertFoodSpot(FoodSpot foodSpot) async {
    final db = await database;
    return await db.insert('food_spots', foodSpot.toMap());
  }
}
