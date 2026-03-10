import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'habit_tracker_v3.db'); 
    return await openDatabase(
      path,
      version: 2, // Incrementamos a versión 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Añadimos manejo de actualizaciones
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de Hábitos
    await db.execute('''
      CREATE TABLE habits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        completedDays TEXT,
        scheduledDays TEXT,
        startTime TEXT,
        endTime TEXT
      )
    ''');
    
    // Tabla de Emociones
    await db.execute('''
      CREATE TABLE mood_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        mood TEXT,
        note TEXT
      )
    ''');

    // Tabla de Estadísticas de Pomodoro
    await db.execute('''
      CREATE TABLE pomodoro_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE,
        total_seconds INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Si el usuario viene de la versión 1, creamos la tabla que le falta
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pomodoro_stats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT UNIQUE,
          total_seconds INTEGER
        )
      ''');
    }
  }
}
