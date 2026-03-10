import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';

abstract class PomodoroLocalDataSource {
  Future<int> getSecondsByDate(String date);
  Future<Map<String, int>> getSecondsForRange(List<String> dates);
  Future<void> saveSeconds(String date, int secondsToAdd);
}

class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  final DatabaseHelper dbHelper;

  PomodoroLocalDataSourceImpl(this.dbHelper);

  @override
  Future<int> getSecondsByDate(String date) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'pomodoro_stats',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (result.isNotEmpty) {
      return result.first['total_seconds'] as int;
    }
    return 0;
  }

  @override
  Future<Map<String, int>> getSecondsForRange(List<String> dates) async {
    final db = await dbHelper.database;
    final Map<String, int> stats = {};
    
    // Inicializar con 0 para asegurar que todos los días existan en el mapa
    for (var date in dates) {
      stats[date] = 0;
    }

    final placeholders = List.filled(dates.length, '?').join(',');
    final result = await db.query(
      'pomodoro_stats',
      where: 'date IN ($placeholders)',
      whereArgs: dates,
    );

    for (var row in result) {
      stats[row['date'] as String] = row['total_seconds'] as int;
    }
    
    return stats;
  }

  @override
  Future<void> saveSeconds(String date, int secondsToAdd) async {
    final db = await dbHelper.database;
    final currentSeconds = await getSecondsByDate(date);
    
    if (currentSeconds == 0) {
      // Intentar insertar si no existe
      await db.insert('pomodoro_stats', {
        'date': date,
        'total_seconds': secondsToAdd,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      // Actualizar si ya existe
      await db.update(
        'pomodoro_stats',
        {'total_seconds': currentSeconds + secondsToAdd},
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }
}
