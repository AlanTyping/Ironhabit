import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final int? id;
  final String name;
  final List<String> completedDays;
  final List<int> scheduledDays;
  final String startTime;
  final String endTime;

  const HabitEntity({
    this.id,
    required this.name,
    this.completedDays = const [],
    required this.scheduledDays,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, name, completedDays, scheduledDays, startTime, endTime];

  HabitEntity copyWith({
    int? id,
    String? name,
    List<String>? completedDays,
    List<int>? scheduledDays,
    String? startTime,
    String? endTime,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      completedDays: completedDays ?? this.completedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
