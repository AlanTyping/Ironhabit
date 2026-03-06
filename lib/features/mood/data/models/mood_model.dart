import '../../domain/entities/mood_entity.dart';

class MoodModel extends MoodEntity {
  const MoodModel({
    super.id,
    required super.date,
    required super.mood,
    super.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'note': note,
    };
  }

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'],
      date: map['date'],
      mood: map['mood'],
      note: map['note'],
    );
  }

  factory MoodModel.fromEntity(MoodEntity entity) {
    return MoodModel(
      id: entity.id,
      date: entity.date,
      mood: entity.mood,
      note: entity.note,
    );
  }
}
