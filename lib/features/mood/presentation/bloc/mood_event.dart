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

class DeleteMoodEvent extends MoodEvent {
  final String date;
  const DeleteMoodEvent(this.date);
  @override
  List<Object?> get props => [date];
}
