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
    // Seguimos usando v3 para mantener la compatibilidad con el esquema de tiempo (De/Hasta)
    String path = join(await getDatabasesPath(), 'habit_tracker_v3.db'); 
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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
  }

  // Métodos de ayuda genéricos (opcionales, ya que los datasources manejan su propia lógica)
  // Pero los mantenemos para evitar errores si otras partes del código los llaman
}
