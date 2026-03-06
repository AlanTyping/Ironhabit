import 'package:equatable/equatable.dart';

class MoodEntity extends Equatable {
  final int? id;
  final String date;
  final String mood;
  final String? note;

  const MoodEntity({
    this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  @override
  List<Object?> get props => [id, date, mood, note];
}
