import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'home.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'tasks';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static const String tableNames = 'tasks';

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'task_database.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskName TEXT,
            description TEXT,
            dueDate TEXT,
            completed INTEGER
          )
          ''',
        );
      },
    );
  }

  static Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  static Future<void> deleteTask(Task task) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
