import '../models/habit_model.dart';
import '../../../../database/database_helper.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getHabits();
  Future<void> insertHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(int id);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final DatabaseHelper dbHelper;

  HabitLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<HabitModel>> getHabits() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => HabitModel.fromMap(maps[i]));
  }

  @override
  Future<void> insertHabit(HabitModel habit) async {
    final db = await dbHelper.database;
    await db.insert('habits', habit.toMap());
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final db = await dbHelper.database;
    await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  @override
  Future<void> deleteHabit(int id) async {
    final db = await dbHelper.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}
