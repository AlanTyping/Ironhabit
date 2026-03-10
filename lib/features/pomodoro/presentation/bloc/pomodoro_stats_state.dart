import 'package:equatable/equatable.dart';

abstract class PomodoroStatsState extends Equatable {
  const PomodoroStatsState();
  @override
  List<Object?> get props => [];
}

class PomodoroStatsLoading extends PomodoroStatsState {}

class PomodoroStatsLoaded extends PomodoroStatsState {
  final Map<DateTime, int> weeklyStats;
  final DateTime weekStartDate;

  const PomodoroStatsLoaded({
    required this.weeklyStats,
    required this.weekStartDate,
  });

  @override
  List<Object?> get props => [weeklyStats, weekStartDate];
}

class PomodoroStatsError extends PomodoroStatsState {
  final String message;
  const PomodoroStatsError(this.message);
  @override
  List<Object?> get props => [message];
}
