import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../../domain/entities/habit_entity.dart';
import '../widgets/habit_tile.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  late ScrollController _dayScrollController;
  int? _lastStreak;
  int _selectedWeekday = DateTime.now().weekday;
  final List<String> _daysShort = [
    'LUN',
    'MAR',
    'MIÉ',
    'JUE',
    'VIE',
    'SÁB',
    'DOM',
  ];

  // Configuración de dimensiones para el scroll
  final double _itemWidth = 70.0;
  final double _itemMargin = 8.0;

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();
    // Ejecutar el scroll al centro después de que se construya el primer frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToDay(_selectedWeekday),
    );
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _scrollToDay(int day) {
    if (!_dayScrollController.hasClients) return;

    // Índice del día (0-6)
    int index = day - 1;
    // Ancho total de un ítem (ancho + márgenes laterales)
    double fullItemWidth = _itemWidth + (_itemMargin * 2);
    // Calcular el centro de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    // Calcular la posición de destino para que el ítem quede en el medio
    double scrollTarget =
        (index * fullItemWidth) - (screenWidth / 2) + (fullItemWidth / 2);

    _dayScrollController.animateTo(
      scrollTarget.clamp(0, _dayScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.ease,
    );
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  int _calculateStreak(List<HabitEntity> habits) {
    final Set<String> completedDates = {};
    for (final habit in habits) {
      completedDates.addAll(habit.completedDays);
    }
    if (completedDates.isEmpty) return 0;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(const Duration(days: 1)));

    int streak = 0;
    DateTime currentDay = now;

    bool completedToday = completedDates.contains(todayStr);
    bool completedYesterday = completedDates.contains(yesterdayStr);

    if (!completedToday && !completedYesterday) {
      return 0;
    }

    if (!completedToday) {
      currentDay = now.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(
      DateFormat('yyyy-MM-dd').format(currentDay),
    )) {
      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void _showStreakIncreaseModal(int newStreak) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF3D0F0F),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.yellow.withAlpha(50), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orangeAccent,
                    size: 80,
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .shake(hz: 4),
              const SizedBox(height: 16),
              Text(
                '¡RACHA INCREMENTADA!',
                style: GoogleFonts.outfit(
                  color: Colors.yellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has alcanzado una racha de $newStreak ${newStreak == 1 ? 'día' : 'días'}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'VOY A SEGUIR',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.ease),
      ),
    );
  }

  void _showAddHabitDialog() async {
    final TextEditingController nameController = TextEditingController();
    List<int> selectedDays = [_selectedWeekday];
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF2D0A0A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nueva Meta',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                '¿QUÉ NOMBRE LE PONDRÁS?',
                style: GoogleFonts.outfit(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej: Meditación diaria',
                  hintStyle: GoogleFonts.outfit(color: Colors.white12),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10, width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'DÍAS DE COMPROMISO',
                style: GoogleFonts.outfit(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  int day = index + 1;
                  bool isDaySelected = selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => setDialogState(
                      () => isDaySelected
                          ? selectedDays.remove(day)
                          : selectedDays.add(day),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDaySelected
                            ? Colors.yellow
                            : Colors.white.withAlpha(5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDaySelected ? Colors.yellow : Colors.white10,
                          width: 2,
                        ),
                        boxShadow: isDaySelected
                            ? [
                                BoxShadow(
                                  color: Colors.yellow.withAlpha(50),
                                  blurRadius: 10,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          _daysShort[index].substring(0, 1),
                          style: GoogleFonts.outfit(
                            color: isDaySelected ? Colors.black : Colors.white38,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              Text(
                'FRANJA HORARIA',
                style: GoogleFonts.outfit(
                  color: Colors.yellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _timeSelector(
                    context,
                    'Inicia',
                    startTime,
                    (t) => setDialogState(() => startTime = t),
                  ),
                  const SizedBox(width: 20),
                  _timeSelector(
                    context,
                    'Termina',
                    endTime,
                    (t) => setDialogState(() => endTime = t),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final String name = nameController.text.trim();
                  if (name.isNotEmpty && selectedDays.isNotEmpty) {
                    final newHabit = HabitEntity(
                      name: name,
                      scheduledDays: selectedDays,
                      startTime: _formatTime(startTime),
                      endTime: _formatTime(endTime),
                    );
                    context.read<HabitBloc>().add(AddHabitEvent(newHabit));
                    Navigator.pop(context);
                  } else if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '¡Ponle un nombre a tu meta!',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF2D0A0A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.yellow,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  'COMENZAR AHORA',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeSelector(
    BuildContext context,
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onSelect,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final t = await showTimePicker(context: context, initialTime: time);
          if (t != null) onSelect(t);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
              ),
              Text(
                _formatTime(time),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Buenos días'
        : now.hour < 20
        ? 'Buenas tardes'
        : 'Buenas noches';

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
          child: BlocConsumer<HabitBloc, HabitState>(
            listener: (context, state) {
              if (state is HabitLoadedState) {
                final currentStreak = _calculateStreak(state.habits);
                if (_lastStreak != null && currentStreak > _lastStreak!) {
                  _showStreakIncreaseModal(currentStreak);
                }
                _lastStreak = currentStreak;
              }
            },
            builder: (context, state) {
              int streak = 0;
              List<HabitEntity> allHabits = [];
              if (state is HabitLoadedState) {
                allHabits = state.habits;
                streak = _calculateStreak(allHabits);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  greeting,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: Colors.white60,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),
                            Text(
                                  'Tus metas de hoy',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                          ],
                        ),
                        // Streak Indicator
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    streak.toString(),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    color: streak > 0
                                        ? Colors.orangeAccent
                                        : Colors.white24,
                                    size: 24,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1),
                            ),
                      ],
                    ),
                  ),

                  // Selector de día con Scroll Centrado
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      controller: _dayScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        int day = index + 1;
                        bool isSelected = _selectedWeekday == day;
                        bool isToday = day == now.weekday;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedWeekday = day);
                            _scrollToDay(day);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _itemWidth,
                            margin: EdgeInsets.symmetric(
                              horizontal: _itemMargin,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.yellow
                                  : Colors.white.withAlpha(5),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.yellow.withAlpha(30),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.yellow
                                    : (isToday
                                          ? Colors.yellow.withAlpha(100)
                                          : Colors.white10),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _daysShort[index],
                                  style: GoogleFonts.outfit(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isSelected)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is HabitLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.yellow,
                            ),
                          );
                        }
                        if (state is HabitLoadedState) {
                          final habits = state.habits
                              .where(
                                (h) =>
                                    h.scheduledDays.contains(_selectedWeekday),
                              )
                              .toList();
                          habits.sort(
                            (a, b) => a.startTime.compareTo(b.startTime),
                          );

                          if (habits.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.rocket_launch_outlined,
                                    size: 64,
                                    color: Colors.white10,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Día libre. ¡Disfruta!',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white24,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              final String todayStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(now);
                              final bool isCompletedToday = habit.completedDays
                                  .contains(todayStr);
                              final bool isTodayReal =
                                  now.weekday == _selectedWeekday;

                              return HabitTile(
                                habit: habit,
                                isCompleted: isCompletedToday,
                                isToday: isTodayReal,
                                onToggle: () => context.read<HabitBloc>().add(
                                  ToggleHabitEvent(habit, todayStr),
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
        ), // Ajuste para que no tape el contenido
        child: FloatingActionButton.extended(
          onPressed: _showAddHabitDialog,
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          elevation: 8,
          label: Text(
            'AÑADIR META',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add_rounded, size: 28),
        ).animate().scale(delay: 400.ms, curve: Curves.ease),
      ),
    );
  }
}
