import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'injection_container.dart' as di;
import 'core/services/notification_service.dart';

// BLoCs
import 'features/habits/presentation/bloc/habit_bloc.dart';
import 'features/habits/presentation/bloc/habit_event.dart';
import 'features/mood/presentation/bloc/mood_bloc.dart';
import 'features/mood/presentation/bloc/mood_event.dart';
import 'features/mood/presentation/bloc/mood_state.dart';
import 'features/mood/domain/entities/mood_entity.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_bloc.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_event.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_stats_bloc.dart';
import 'features/pomodoro/presentation/bloc/pomodoro_stats_event.dart';

// Pages
import 'features/habits/presentation/pages/habit_page.dart';
import 'features/mood/presentation/pages/mood_page.dart';
import 'features/pomodoro/presentation/pages/pomodoro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await di.init();
  await di.sl<NotificationService>().init();

  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<HabitBloc>()..add(LoadHabitsEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<MoodBloc>()..add(LoadMoodsEvent()),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<PomodoroBloc>()..add(LoadPomodoroSettings()),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<PomodoroStatsBloc>()..add(LoadWeeklyStats(DateTime.now())),
        ),
      ],
      child: MaterialApp(
        title: 'Ironhabit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A0505),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.yellow,
            brightness: Brightness.dark,
            surface: const Color(0xFF2D0A0A),
            primary: Colors.yellow,
            onSurface: Colors.white,
          ),
          useMaterial3: true,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF2D0A0A),
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white24,
            selectedLabelStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
            selectedIconTheme: const IconThemeData(
              size: 32,
            ), // Iconos más grandes
            unselectedIconTheme: const IconThemeData(size: 28),
            type: BottomNavigationBarType.fixed,
            elevation: 20,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HabitPage(),
    const PomodoroPage(),
    const MoodPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowMoodDialog();
    });
  }

  Future<void> _checkAndShowMoodDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    
    final lastOpenDate = prefs.getString('last_open_date') ?? '';
    int openCount = prefs.getInt('open_count') ?? 0;

    if (lastOpenDate != today) {
      // Es el primer inicio del día
      await prefs.setString('last_open_date', today);
      await prefs.setInt('open_count', 1);
      return;
    } else {
      // Ya se abrió hoy, incrementamos contador
      openCount++;
      await prefs.setInt('open_count', openCount);
    }

    // Si es la segunda vez (o más) que abre la app hoy
    if (openCount >= 2) {
      // Verificamos si ya tiene mood hoy
      final moodBloc = context.read<MoodBloc>();
      if (moodBloc.state is MoodLoadedState) {
        final moodMap = (moodBloc.state as MoodLoadedState).moodMap;
        if (moodMap.containsKey(today)) {
          // Ya tiene mood, no molestamos
          return;
        }
      }

      // Si llegamos aquí, mostramos el modal
      if (mounted) {
        _showMoodDialog(context, today);
      }
    }
  }

  void _showMoodDialog(BuildContext context, String todayStr) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2D0A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo te sientes hoy?',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _moodOption(context, 'happy', '😊', 'Bien', todayStr),
                  _moodOption(context, 'neutral', '😐', 'Normal', todayStr),
                  _moodOption(context, 'sad', '😢', 'Mal', todayStr),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'MÁS TARDE',
                  style: GoogleFonts.outfit(color: Colors.white24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodOption(BuildContext context, String mood, String emoji, String label, String dateStr) {
    return GestureDetector(
      onTap: () {
        context.read<MoodBloc>().add(
          SaveMoodEvent(MoodEntity(date: dateStr, mood: mood)),
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado de ánimo guardado'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.yellow,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_rounded),
            activeIcon: Icon(Icons.bolt_rounded),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            activeIcon: Icon(Icons.timer_rounded),
            label: 'Enfoque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_rounded),
            activeIcon: Icon(Icons.auto_awesome_mosaic_rounded),
            label: 'Clima',
          ),
        ],
      ),
    );
  }
}
