import 'package:equatable/equatable.dart';
import 'pomodoro_state.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class LoadPomodoroSettings extends PomodoroEvent {}

class StartTimer extends PomodoroEvent {}

class PauseTimer extends PomodoroEvent {}

class ResetTimer extends PomodoroEvent {}

class Tick extends PomodoroEvent {}

class SetDuration extends PomodoroEvent {
  final int minutes;
  const SetDuration(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

class ChangeFocusMode extends PomodoroEvent {
  final FocusMode mode;
  const ChangeFocusMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
