import 'package:frontend/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthLocaleRepository {
  String tableName = "users";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "auth.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE $tableName (
          id TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          token TEXT NOT NULL,
          name TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final result = await db.query(tableName, limit: 1);
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }
}
