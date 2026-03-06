import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';
import '../bloc/mood_state.dart';
import '../../domain/entities/mood_entity.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _saveMood(String mood) {
    if (_selectedDay == null) return;
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    context.read<MoodBloc>().add(
      SaveMoodEvent(MoodEntity(date: dateStr, mood: mood)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D0A0A), Color(0xFF1A0505)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false, // Permitir que el contenido fluya bajo el navbar
          child: BlocBuilder<MoodBloc, MoodState>(
            builder: (context, state) {
              Map<String, String> moodMap = {};
              if (state is MoodLoadedState) moodMap = state.moodMap;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Tu Clima Interior',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    ),

                    Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(5),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: CalendarFormat.month,
                            rowHeight: 45, // Altura de fila algo más compacta
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),

                              leftChevronIcon: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.yellow,
                              ),
                              rightChevronIcon: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.yellow,
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                              weekendStyle: GoogleFonts.outfit(
                                color: Colors.white24,
                                fontSize: 12,
                              ),
                            ),
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) =>
                                  _buildDayCell(
                                    day,
                                    moodMap,
                                    isSelected: false,
                                    isToday: false,
                                  ),
                              todayBuilder: (context, day, focusedDay) =>
                                  _buildDayCell(
                                    day,
                                    moodMap,
                                    isSelected: false,
                                    isToday: true,
                                  ),
                              selectedBuilder: (context, day, focusedDay) =>
                                  _buildDayCell(
                                    day,
                                    moodMap,
                                    isSelected: true,
                                    isToday: false,
                                  ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),

                    const SizedBox(height: 24),

                    if (_selectedDay != null)
                      _buildMoodPicker(moodMap)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.3, end: 0),

                    const SizedBox(
                      height: 100,
                    ), // Espacio para el Navbar flotante
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Map<String, String> moodMap, {
    required bool isSelected,
    required bool isToday,
  }) {
    String dateStr = DateFormat('yyyy-MM-dd').format(day);
    String? mood = moodMap[dateStr];

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.yellow
              : (isToday ? Colors.yellow.withAlpha(20) : Colors.transparent),
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 2)
              : (isToday
                    ? Border.all(color: Colors.yellow.withAlpha(100))
                    : null),
        ),
        child: mood != null
            ? Text(_getEmoji(mood), style: const TextStyle(fontSize: 22))
            : Text(
                '${day.day}',
                style: GoogleFonts.outfit(
                  color: isSelected
                      ? Colors.black
                      : (isToday ? Colors.yellow : Colors.white70),
                  fontWeight: isToday || isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildMoodPicker(Map<String, String> moodMap) {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    String? currentMood = moodMap[dateStr];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF3D0F0F),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              DateFormat('EEEE, dd MMMM').format(_selectedDay!),
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white38),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Cómo te sientes?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _moodOption('happy', '😊', 'Bien', currentMood),
                _moodOption('neutral', '😐', 'Normal', currentMood),
                _moodOption('sad', '😢', 'Mal', currentMood),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodOption(
    String mood,
    String emoji,
    String label,
    String? selectedMood,
  ) {
    bool isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () => _saveMood(mood),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.yellow : Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.white10,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.yellow.withAlpha(30),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.yellow : Colors.white38,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😢';
      default:
        return '';
    }
  }
}
