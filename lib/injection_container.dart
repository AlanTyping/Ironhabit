import 'package:get_it/get_it.dart';
import 'database/database_helper.dart';

// Habits Feature
import 'features/habits/data/datasources/habit_local_datasource.dart';
import 'features/habits/data/repositories/habit_repository_impl.dart';
import 'features/habits/domain/repositories/habit_repository.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';

// Mood Feature
import 'features/mood/data/datasources/mood_local_datasource.dart';
import 'features/mood/data/repositories/mood_repository_impl.dart';
import 'features/mood/domain/repositories/mood_repository.dart';
import 'features/mood/presentation/bloc/mood_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Habits
  // BLoC
  sl.registerFactory(() => HabitBloc(sl()));
  // Repository
  sl.registerLazySingleton<HabitRepository>(() => HabitRepositoryImpl(sl()));
  // Data sources
  sl.registerLazySingleton<HabitLocalDataSource>(() => HabitLocalDataSourceImpl(sl()));

  //! Features - Mood
  // BLoC
  sl.registerFactory(() => MoodBloc(sl()));
  // Repository
  sl.registerLazySingleton<MoodRepository>(() => MoodRepositoryImpl(sl()));
  // Data sources
  sl.registerLazySingleton<MoodLocalDataSource>(() => MoodLocalDataSourceImpl(sl()));

  //! External
  sl.registerLazySingleton(() => DatabaseHelper());
}
