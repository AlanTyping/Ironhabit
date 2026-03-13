import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/pomodoro_local_datasource.dart';
import '../../../../core/services/notification_service.dart';
import 'pomodoro_event.dart';
import 'pomodoro_state.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroLocalDataSource dataSource;
  final NotificationService notificationService;
  StreamSubscription<int>? _tickerSubscription;
  static const String _prefMinutesKey = 'pomodoro_duration';
  static const String _prefEndTimeKey = 'pomodoro_expected_end_time';
  static const String _prefStopwatchStartTimeKey = 'pomodoro_stopwatch_start_time';
  static const String _prefModeKey = 'pomodoro_focus_mode';
  static const String _prefLastSyncWorkedSecondsKey = 'pomodoro_last_sync_worked_seconds';
  
  int? _workedSecondsAtLastSync;

  PomodoroBloc(this.dataSource, this.notificationService) : super(PomodoroState.initial()) {
    on<LoadPomodoroSettings>(_onLoadSettings);
    on<StartTimer>(_onStart);
    on<PauseTimer>(_onPause);
    on<ResetTimer>(_onReset);
    on<Tick>(_onTick);
    on<SetDuration>(_onSetDuration);
    on<ChangeFocusMode>(_onChangeFocusMode);
  }

  String _getToday() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _onLoadSettings(LoadPomodoroSettings event, Emitter<PomodoroState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedMinutes = prefs.getInt(_prefMinutesKey) ?? 25;
    final endTimeStr = prefs.getString(_prefEndTimeKey);
    final stopwatchStartTimeStr = prefs.getString(_prefStopwatchStartTimeKey);
    final modeStr = prefs.getString(_prefModeKey) ?? 'pomodoro';
    final todaySeconds = await dataSource.getSecondsByDate(_getToday());
    
    _workedSecondsAtLastSync = prefs.getInt(_prefLastSyncWorkedSecondsKey) ?? 0;
    
    final FocusMode mode = modeStr == 'freeTime' ? FocusMode.freeTime : FocusMode.pomodoro;
    final totalSeconds = savedMinutes * 60;

    if (mode == FocusMode.pomodoro && endTimeStr != null) {
      final expectedEndTime = DateTime.tryParse(endTimeStr);
      if (expectedEndTime != null) {
        final now = DateTime.now();
        if (expectedEndTime.isAfter(now)) {
          final remaining = expectedEndTime.difference(now).inSeconds;
          // _workedSecondsAtLastSync ya se cargó de prefs
          emit(state.copyWith(
            defaultMinutes: savedMinutes,
            totalSeconds: totalSeconds,
            remainingSeconds: remaining,
            status: PomodoroStatus.running,
            expectedEndTime: expectedEndTime,
            dailySeconds: todaySeconds,
            mode: FocusMode.pomodoro,
          ));
          _startTicker();
          return;
        } else {
          await prefs.remove(_prefEndTimeKey);
          await prefs.remove(_prefLastSyncWorkedSecondsKey);
          emit(state.copyWith(
            defaultMinutes: savedMinutes,
            totalSeconds: totalSeconds,
            remainingSeconds: 0,
            status: PomodoroStatus.finished,
            clearExpectedEndTime: true,
            dailySeconds: todaySeconds,
            mode: FocusMode.pomodoro,
          ));
          return;
        }
      }
    } else if (mode == FocusMode.freeTime && stopwatchStartTimeStr != null) {
      final startTime = DateTime.tryParse(stopwatchStartTimeStr);
      if (startTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(startTime).inSeconds;
        // _workedSecondsAtLastSync ya se cargó de prefs
        emit(state.copyWith(
          defaultMinutes: savedMinutes,
          totalSeconds: totalSeconds,
          stopwatchSeconds: elapsed,
          status: PomodoroStatus.running,
          stopwatchStartTime: startTime,
          dailySeconds: todaySeconds,
          mode: FocusMode.freeTime,
        ));
        _startTicker();
        return;
      }
    }

    emit(state.copyWith(
      defaultMinutes: savedMinutes,
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      stopwatchSeconds: 0,
      status: PomodoroStatus.initial,
      mode: mode,
      clearExpectedEndTime: true,
      clearStopwatchStartTime: true,
      dailySeconds: todaySeconds,
    ));
  }

  void _startTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x)
        .listen((_) => add(Tick()));
  }

  Future<void> _onStart(StartTimer event, Emitter<PomodoroState> emit) async {
    if (state.status == PomodoroStatus.running) return;

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    if (state.mode == FocusMode.pomodoro) {
      final expectedEndTime = now.add(Duration(seconds: state.remainingSeconds));
      _workedSecondsAtLastSync = state.totalSeconds - state.remainingSeconds;
      await prefs.setString(_prefEndTimeKey, expectedEndTime.toIso8601String());
      await prefs.setInt(_prefLastSyncWorkedSecondsKey, _workedSecondsAtLastSync!);
      emit(state.copyWith(status: PomodoroStatus.running, expectedEndTime: expectedEndTime));
    } else {
      // En modo libre, el startTime es ahora menos lo que ya llevábamos (si pausamos y reanudamos)
      final stopwatchStartTime = now.subtract(Duration(seconds: state.stopwatchSeconds));
      _workedSecondsAtLastSync = state.stopwatchSeconds;
      await prefs.setString(_prefStopwatchStartTimeKey, stopwatchStartTime.toIso8601String());
      await prefs.setInt(_prefLastSyncWorkedSecondsKey, _workedSecondsAtLastSync!);
      emit(state.copyWith(status: PomodoroStatus.running, stopwatchStartTime: stopwatchStartTime));
    }
    
    _startTicker();
  }

  Future<void> _onPause(PauseTimer event, Emitter<PomodoroState> emit) async {
    _tickerSubscription?.cancel();
    await _syncWorkedTime();
    await notificationService.cancelNotification();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefEndTimeKey);
    await prefs.remove(_prefStopwatchStartTimeKey);
    // No removemos _prefLastSyncWorkedSecondsKey porque queremos reanudar desde ahí

    final todaySeconds = await dataSource.getSecondsByDate(_getToday());
    emit(state.copyWith(
      status: PomodoroStatus.paused,
      clearExpectedEndTime: true,
      clearStopwatchStartTime: true,
      dailySeconds: todaySeconds,
    ));
  }

  Future<void> _onReset(ResetTimer event, Emitter<PomodoroState> emit) async {
    _tickerSubscription?.cancel();
    if (state.status == PomodoroStatus.running) {
      await _syncWorkedTime();
    }
    await notificationService.cancelNotification();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefEndTimeKey);
    await prefs.remove(_prefStopwatchStartTimeKey);
    await prefs.remove(_prefLastSyncWorkedSecondsKey);
    _workedSecondsAtLastSync = 0;

    final todaySeconds = await dataSource.getSecondsByDate(_getToday());
    emit(state.copyWith(
      remainingSeconds: state.totalSeconds,
      stopwatchSeconds: 0,
      status: PomodoroStatus.initial,
      clearExpectedEndTime: true,
      clearStopwatchStartTime: true,
      dailySeconds: todaySeconds,
    ));
  }

  Future<void> _onTick(Tick event, Emitter<PomodoroState> emit) async {
    final now = DateTime.now();
    
    if (state.mode == FocusMode.pomodoro && state.expectedEndTime != null) {
      if (state.expectedEndTime!.isAfter(now)) {
        final remaining = state.expectedEndTime!.difference(now).inSeconds;
        emit(state.copyWith(remainingSeconds: remaining));
        _updateNotification(remaining);
      } else {
        _tickerSubscription?.cancel();
        await _syncWorkedTime();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefEndTimeKey);
        await prefs.remove(_prefLastSyncWorkedSecondsKey);
        _workedSecondsAtLastSync = 0;
        final todaySeconds = await dataSource.getSecondsByDate(_getToday());
        emit(state.copyWith(remainingSeconds: 0, status: PomodoroStatus.finished, clearExpectedEndTime: true, dailySeconds: todaySeconds));
        notificationService.showTimerNotification(
          title: '¡Sesión Terminada!',
          content: 'Buen trabajo enfocado.',
          isOngoing: false,
        );
      }
    } else if (state.mode == FocusMode.freeTime && state.stopwatchStartTime != null) {
      final elapsed = now.difference(state.stopwatchStartTime!).inSeconds;
      emit(state.copyWith(stopwatchSeconds: elapsed));
      _updateNotification(elapsed);
      // Sincronización proactiva cada 30 segundos en modo libre
      if (elapsed % 30 == 0) {
        await _syncWorkedTime();
        final todaySeconds = await dataSource.getSecondsByDate(_getToday());
        emit(state.copyWith(dailySeconds: todaySeconds));
      }
    }
  }

  void _updateNotification(int seconds) {
    final title = state.mode == FocusMode.pomodoro ? 'Sesión de Enfoque' : 'Tiempo Libre';
    notificationService.showTimerNotification(
      title: title,
      content: _formatTime(seconds),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _syncWorkedTime() async {
    int workedNow = state.mode == FocusMode.pomodoro 
        ? (state.totalSeconds - state.remainingSeconds) 
        : state.stopwatchSeconds;
    
    if (_workedSecondsAtLastSync != null) {
      final diff = workedNow - _workedSecondsAtLastSync!;
      if (diff > 0) {
        DateTime startTime;
        if (state.mode == FocusMode.pomodoro && state.expectedEndTime != null) {
          startTime = state.expectedEndTime!.subtract(Duration(seconds: state.totalSeconds - _workedSecondsAtLastSync!));
        } else if (state.mode == FocusMode.freeTime && state.stopwatchStartTime != null) {
          startTime = state.stopwatchStartTime!.add(Duration(seconds: _workedSecondsAtLastSync!));
        } else {
          // Fallback al comportamiento anterior si faltan tiempos
          await dataSource.saveSeconds(_getToday(), diff);
          _workedSecondsAtLastSync = workedNow;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_prefLastSyncWorkedSecondsKey, workedNow);
          return;
        }

        final endTime = startTime.add(Duration(seconds: diff));
        await _saveDistributedSeconds(startTime, endTime);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefLastSyncWorkedSecondsKey, workedNow);
      }
    }
    _workedSecondsAtLastSync = workedNow;
  }

  Future<void> _saveDistributedSeconds(DateTime startTime, DateTime endTime) async {
    DateTime current = startTime;
    while (current.year != endTime.year || current.month != endTime.month || current.day != endTime.day) {
      DateTime nextDay = DateTime(current.year, current.month, current.day + 1);
      int secondsInThisDay = nextDay.difference(current).inSeconds;
      await dataSource.saveSeconds(DateFormat('yyyy-MM-dd').format(current), secondsInThisDay);
      current = nextDay;
    }
    int remainingSeconds = endTime.difference(current).inSeconds;
    if (remainingSeconds > 0) {
      await dataSource.saveSeconds(DateFormat('yyyy-MM-dd').format(current), remainingSeconds);
    }
  }

  Future<void> _onSetDuration(SetDuration event, Emitter<PomodoroState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMinutesKey, event.minutes);
    await prefs.remove(_prefLastSyncWorkedSecondsKey);
    _workedSecondsAtLastSync = 0;
    await notificationService.cancelNotification();
    
    _tickerSubscription?.cancel();
    final totalSeconds = event.minutes * 60;
    emit(state.copyWith(
      defaultMinutes: event.minutes,
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      status: PomodoroStatus.initial,
      clearExpectedEndTime: true,
    ));
  }

  Future<void> _onChangeFocusMode(ChangeFocusMode event, Emitter<PomodoroState> emit) async {
    if (state.status == PomodoroStatus.running) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModeKey, event.mode == FocusMode.freeTime ? 'freeTime' : 'pomodoro');
    await prefs.remove(_prefLastSyncWorkedSecondsKey);
    _workedSecondsAtLastSync = 0;
    await notificationService.cancelNotification();
    
    emit(state.copyWith(
      mode: event.mode,
      status: PomodoroStatus.initial,
      remainingSeconds: state.totalSeconds,
      stopwatchSeconds: 0,
      clearExpectedEndTime: true,
      clearStopwatchStartTime: true,
    ));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
