import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/mood_repository.dart';
import 'mood_event.dart';
import 'mood_state.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository repository;

  MoodBloc(this.repository) : super(MoodInitialState()) {
    on<LoadMoodsEvent>((event, emit) async {
      emit(MoodLoadingState());
      try {
        final moods = await repository.getAllMoods();
        final Map<String, String> moodMap = {for (var m in moods) m.date: m.mood};
        emit(MoodLoadedState(moodMap));
      } catch (e) {
        emit(MoodErrorState(e.toString()));
      }
    });

    on<SaveMoodEvent>((event, emit) async {
      try {
        await repository.saveMood(event.mood);
        add(LoadMoodsEvent());
      } catch (e) {
        emit(MoodErrorState(e.toString()));
      }
    });

    on<DeleteMoodEvent>((event, emit) async {
      try {
        await repository.deleteMood(event.date);
        add(LoadMoodsEvent());
      } catch (e) {
        emit(MoodErrorState(e.toString()));
      }
    });
  }
}
