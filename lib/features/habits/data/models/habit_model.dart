import '../../domain/entities/habit_entity.dart';

class HabitModel extends HabitEntity {
  const HabitModel({
    super.id,
    required super.name,
    super.completedDays,
    required super.scheduledDays,
    required super.startTime,
    required super.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'completedDays': completedDays.join(','),
      'scheduledDays': scheduledDays.join(','),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      name: map['name'],
      completedDays: map['completedDays'] != null && map['completedDays'].toString().isNotEmpty
          ? map['completedDays'].toString().split(',')
          : [],
      scheduledDays: map['scheduledDays'] != null && map['scheduledDays'].toString().isNotEmpty
          ? map['scheduledDays'].toString().split(',').map((e) => int.parse(e)).toList()
          : [],
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '09:00',
    );
  }

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      completedDays: entity.completedDays,
      scheduledDays: entity.scheduledDays,
      startTime: entity.startTime,
      endTime: entity.endTime,
    );
  }
}
