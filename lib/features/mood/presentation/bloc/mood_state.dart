import 'package:equatable/equatable.dart';

abstract class MoodState extends Equatable {
  const MoodState();
  @override
  List<Object?> get props => [];
}

class MoodInitialState extends MoodState {}

class MoodLoadingState extends MoodState {}

class MoodLoadedState extends MoodState {
  final Map<String, String> moodMap;
  const MoodLoadedState(this.moodMap);
  @override
  List<Object?> get props => [moodMap];
}

class MoodErrorState extends MoodState {
  final String message;
  const MoodErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
