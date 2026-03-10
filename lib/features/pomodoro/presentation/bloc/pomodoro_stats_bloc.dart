import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/pomodoro_local_datasource.dart';
import 'pomodoro_stats_event.dart';
import 'pomodoro_stats_state.dart';

class PomodoroStatsBloc extends Bloc<PomodoroStatsEvent, PomodoroStatsState> {
  final PomodoroLocalDataSource dataSource;

  PomodoroStatsBloc(this.dataSource) : super(PomodoroStatsLoading()) {
    on<LoadWeeklyStats>(_onLoadWeeklyStats);
  }

  Future<void> _onLoadWeeklyStats(LoadWeeklyStats event, Emitter<PomodoroStatsState> emit) async {
    emit(PomodoroStatsLoading());
    try {
      // Calcular el lunes de la semana solicitada
      final DateTime date = event.weekDate;
      final int daysToMonday = date.weekday - 1;
      final DateTime monday = DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToMonday));
      
      final List<DateTime> weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
      final List<String> dateStrings = weekDays.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

      final Map<String, int> rawStats = await dataSource.getSecondsForRange(dateStrings);
      
      final Map<DateTime, int> weeklyStats = {};
      for (int i = 0; i < weekDays.length; i++) {
        weeklyStats[weekDays[i]] = rawStats[dateStrings[i]] ?? 0;
      }

      emit(PomodoroStatsLoaded(
        weeklyStats: weeklyStats,
        weekStartDate: monday,
      ));
    } catch (e) {
      emit(PomodoroStatsError(e.toString()));
    }
  }
}
