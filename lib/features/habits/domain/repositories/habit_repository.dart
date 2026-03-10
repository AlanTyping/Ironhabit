import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<List<HabitEntity>> getHabits();
  Future<void> saveHabit(HabitEntity habit);
  Future<void> updateHabit(HabitEntity habit);
  Future<void> deleteHabit(int id);
}
