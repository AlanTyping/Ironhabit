import 'package:equatable/equatable.dart';

enum PomodoroStatus { initial, running, paused, finished }
enum FocusMode { pomodoro, freeTime }

class PomodoroState extends Equatable {
  final int totalSeconds;
  final int remainingSeconds;
  final int stopwatchSeconds; // Para el conteo ascendente en Modo Libre
  final PomodoroStatus status;
  final FocusMode mode;
  final int defaultMinutes;
  final DateTime? expectedEndTime; 
  final DateTime? stopwatchStartTime; // Cuándo inició el cronómetro libre
  final int dailySeconds;

  const PomodoroState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.stopwatchSeconds,
    required this.status,
    required this.mode,
    required this.defaultMinutes,
    required this.dailySeconds,
    this.expectedEndTime,
    this.stopwatchStartTime,
  });

  factory PomodoroState.initial() {
    return const PomodoroState(
      totalSeconds: 1500,
      remainingSeconds: 1500,
      stopwatchSeconds: 0,
      status: PomodoroStatus.initial,
      mode: FocusMode.pomodoro,
      defaultMinutes: 25,
      dailySeconds: 0,
    );
  }

  PomodoroState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    int? stopwatchSeconds,
    PomodoroStatus? status,
    FocusMode? mode,
    int? defaultMinutes,
    DateTime? expectedEndTime,
    DateTime? stopwatchStartTime,
    int? dailySeconds,
    bool clearExpectedEndTime = false,
    bool clearStopwatchStartTime = false,
  }) {
    return PomodoroState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      stopwatchSeconds: stopwatchSeconds ?? this.stopwatchSeconds,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      defaultMinutes: defaultMinutes ?? this.defaultMinutes,
      dailySeconds: dailySeconds ?? this.dailySeconds,
      expectedEndTime: clearExpectedEndTime ? null : (expectedEndTime ?? this.expectedEndTime),
      stopwatchStartTime: clearStopwatchStartTime ? null : (stopwatchStartTime ?? this.stopwatchStartTime),
    );
  }

  @override
  List<Object?> get props => [
    totalSeconds,
    remainingSeconds,
    stopwatchSeconds,
    status,
    mode,
    defaultMinutes,
    expectedEndTime,
    stopwatchStartTime,
    dailySeconds,
  ];
}
