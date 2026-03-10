import 'package:equatable/equatable.dart';

abstract class PomodoroStatsEvent extends Equatable {
  const PomodoroStatsEvent();
  @override
  List<Object?> get props => [];
}

class LoadWeeklyStats extends PomodoroStatsEvent {
  final DateTime weekDate; // Una fecha dentro de la semana que se quiere cargar
  const LoadWeeklyStats(this.weekDate);
  @override
  List<Object?> get props => [weekDate];
}
