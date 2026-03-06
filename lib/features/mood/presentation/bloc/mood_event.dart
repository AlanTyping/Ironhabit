import 'package:equatable/equatable.dart';
import '../../domain/entities/mood_entity.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();
  @override
  List<Object?> get props => [];
}

class LoadMoodsEvent extends MoodEvent {}

class SaveMoodEvent extends MoodEvent {
  final MoodEntity mood;
  const SaveMoodEvent(this.mood);
  @override
  List<Object?> get props => [mood];
}
