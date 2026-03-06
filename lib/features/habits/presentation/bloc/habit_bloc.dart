import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/habit_repository.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitRepository repository;

  HabitBloc(this.repository) : super(HabitInitialState()) {
    on<LoadHabitsEvent>((event, emit) async {
      emit(HabitLoadingState());
      try {
        final habits = await repository.getHabits();
        emit(HabitLoadedState(habits));
      } catch (e) {
        emit(HabitErrorState(e.toString()));
      }
    });

    on<AddHabitEvent>((event, emit) async {
      try {
        print("añadiendo nuevo habito");
        print(event.habit);
        await repository.saveHabit(event.habit);
        add(LoadHabitsEvent());
      } catch (e) {
        emit(HabitErrorState(e.toString()));
      }
    });

    on<ToggleHabitEvent>((event, emit) async {
      try {
        List<String> updatedDays = List.from(event.habit.completedDays);
        if (updatedDays.contains(event.date)) {
          updatedDays.remove(event.date);
        } else {
          updatedDays.add(event.date);
        }
        await repository.updateHabit(
          event.habit.copyWith(completedDays: updatedDays),
        );
        add(LoadHabitsEvent());
      } catch (e) {
        emit(HabitErrorState(e.toString()));
      }
    });
  }
}
