import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl(this.localDataSource);

  @override
  Future<List<HabitEntity>> getHabits() async {
    return await localDataSource.getHabits();
  }

  @override
  Future<void> saveHabit(HabitEntity habit) async {
    await localDataSource.insertHabit(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    await localDataSource.updateHabit(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> deleteHabit(int id) async {
    await localDataSource.deleteHabit(id);
  }
}
