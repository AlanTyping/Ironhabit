import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entity.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();
  @override
  List<Object?> get props => [];
}

class LoadHabitsEvent extends HabitEvent {}

class AddHabitEvent extends HabitEvent {
  final HabitEntity habit;
  const AddHabitEvent(this.habit);
  @override
  List<Object?> get props => [habit];
}

class ToggleHabitEvent extends HabitEvent {
  final HabitEntity habit;
  final String date;
  const ToggleHabitEvent(this.habit, this.date);
  @override
  List<Object?> get props => [habit, date];
}

class DeleteHabitEvent extends HabitEvent {
  final int id;
  const DeleteHabitEvent(this.id);
  @override
  List<Object?> get props => [id];
}
