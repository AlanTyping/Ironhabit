import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entity.dart';

abstract class HabitState extends Equatable {
  const HabitState();
  @override
  List<Object?> get props => [];
}

class HabitInitialState extends HabitState {}

class HabitLoadingState extends HabitState {}

class HabitLoadedState extends HabitState {
  final List<HabitEntity> habits;
  const HabitLoadedState(this.habits);
  @override
  List<Object?> get props => [habits];
}

class HabitErrorState extends HabitState {
  final String message;
  const HabitErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
