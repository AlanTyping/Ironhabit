import '../entities/mood_entity.dart';

abstract class MoodRepository {
  Future<List<MoodEntity>> getAllMoods();
  Future<void> saveMood(MoodEntity mood);
}
