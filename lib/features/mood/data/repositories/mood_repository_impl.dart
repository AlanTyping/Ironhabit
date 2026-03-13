import '../../domain/entities/mood_entity.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_datasource.dart';
import '../models/mood_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodLocalDataSource localDataSource;

  MoodRepositoryImpl(this.localDataSource);

  @override
  Future<List<MoodEntity>> getAllMoods() async {
    return await localDataSource.getMoods();
  }

  @override
  Future<void> saveMood(MoodEntity mood) async {
    await localDataSource.insertMood(MoodModel.fromEntity(mood));
  }

  @override
  Future<void> deleteMood(String date) async {
    await localDataSource.deleteMood(date);
  }
}
