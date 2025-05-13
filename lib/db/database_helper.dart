import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/portfolio.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('robokalam.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE portfolio (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      college TEXT NOT NULL,
      skills TEXT NOT NULL,
      projectTitle TEXT NOT NULL,
      projectDescription TEXT NOT NULL
    )
    ''');
  }

  Future<int> insertPortfolio(Portfolio portfolio) async {
    final db = await instance.database;
    return await db.insert('portfolio', portfolio.toMap());
  }

  Future<int> updatePortfolio(Portfolio portfolio) async {
    final db = await instance.database;
    return await db.update(
      'portfolio',
      portfolio.toMap(),
      where: 'id = ?',
      whereArgs: [portfolio.id],
    );
  }

  Future<Portfolio?> getPortfolio() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('portfolio');

    if (maps.isNotEmpty) {
      return Portfolio.fromMap(maps.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}