import 'package:sqflite/sqflite.dart';
import '../models/mood_model.dart';
import '../../../../database/database_helper.dart';

abstract class MoodLocalDataSource {
  Future<List<MoodModel>> getMoods();
  Future<void> insertMood(MoodModel mood);
}

class MoodLocalDataSourceImpl implements MoodLocalDataSource {
  final DatabaseHelper dbHelper;

  MoodLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<MoodModel>> getMoods() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('mood_entries');
    return List.generate(maps.length, (i) => MoodModel.fromMap(maps[i]));
  }

  @override
  Future<void> insertMood(MoodModel mood) async {
    final db = await dbHelper.database;
    await db.insert('mood_entries', mood.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
