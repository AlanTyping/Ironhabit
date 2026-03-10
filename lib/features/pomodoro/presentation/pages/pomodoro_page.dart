import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/pomodoro_bloc.dart';
import '../bloc/pomodoro_event.dart';
import '../bloc/pomodoro_state.dart';

// Pages
import 'pomodoro_stats_page.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSettingsDialog(BuildContext context, int currentMinutes) {
    int selectedMinutes = currentMinutes;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF2D0A0A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configurar Enfoque',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _adjustButton(Icons.remove, () {
                      if (selectedMinutes > 1) {
                        setDialogState(() => selectedMinutes--);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        '$selectedMinutes min',
                        style: GoogleFonts.outfit(
                          color: Colors.yellow,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _adjustButton(Icons.add, () {
                      if (selectedMinutes < 120) {
                        setDialogState(() => selectedMinutes++);
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    context.read<PomodoroBloc>().add(SetDuration(selectedMinutes));
                    Navigator.pop(context);
                  },
                  child: Text('GUARDAR', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adjustButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  String _formatTotalTime(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
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
          child: BlocBuilder<PomodoroBloc, PomodoroState>(
            builder: (context, state) {
              final bool isPomodoro = state.mode == FocusMode.pomodoro;
              final bool isRunning = state.status == PomodoroStatus.running;
              final progress = isPomodoro 
                  ? (state.remainingSeconds / state.totalSeconds)
                  : 1.0;

              return Column(
                children: [
                  // 1. Header Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enfoque',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cultiva tu disciplina',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _iconAction(
                              icon: Icons.bar_chart_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PomodoroStatsPage()),
                              ),
                            ),
                            if (isPomodoro) ...[
                              const SizedBox(width: 8),
                              _iconAction(
                                icon: Icons.settings_outlined,
                                onTap: () => _showSettingsDialog(context, state.defaultMinutes),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                  
                  const Spacer(flex: 2), // Empuja todo hacia abajo para centrar el círculo
                  
                  // 2. Today's Progress (Now ABOVE the timer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.yellow, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'HOY: ',
                          style: GoogleFonts.outfit(
                            color: Colors.white24,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _formatTotalTime(state.dailySeconds),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),
                  
                  // 3. Main Visual Center (Timer)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse Effect for Free Mode
                      if (isRunning && !isPomodoro)
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withAlpha(15),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut),

                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withAlpha(5),
                          color: isRunning ? Colors.yellow : Colors.white10,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(isPomodoro ? state.remainingSeconds : state.stopwatchSeconds),
                            style: GoogleFonts.outfit(
                              fontSize: 72,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRunning 
                                ? (isPomodoro ? 'TEMPORIZADOR' : 'TIEMPO LIBRE') 
                                : 'LISTO PARA INICIAR',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.yellow.withAlpha(180),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const Spacer(flex: 3), // Más flex abajo para elevar visualmente el círculo al centro real
                  
                  // 4. Control Block (Actions + Mode Selector)
                  Column(
                    children: [
                      // Action Buttons Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _controlButton(
                              icon: Icons.stop_rounded,
                              onTap: () => context.read<PomodoroBloc>().add(ResetTimer()),
                              isSecondary: true,
                            ),
                            _controlButton(
                              icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              onTap: () {
                                if (isRunning) {
                                  context.read<PomodoroBloc>().add(PauseTimer());
                                } else {
                                  context.read<PomodoroBloc>().add(StartTimer());
                                }
                              },
                              isLarge: true,
                            ),
                            _controlButton(
                              icon: Icons.refresh_rounded,
                              onTap: () {
                                 context.read<PomodoroBloc>().add(ResetTimer());
                                 if (isRunning) context.read<PomodoroBloc>().add(StartTimer());
                              },
                              isSecondary: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                      // Animated spacing and switcher
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        height: isRunning ? 0 : 80,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: isRunning ? 0.0 : 1.0,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      _modeToggleOption(context, 'POMODORO', FocusMode.pomodoro, state.mode),
                                      _modeToggleOption(context, 'LIBRE', FocusMode.freeTime, state.mode),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _iconAction({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white60, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _modeToggleOption(BuildContext context, String label, FocusMode mode, FocusMode currentMode) {
    final bool isSelected = mode == currentMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<PomodoroBloc>().add(ChangeFocusMode(mode)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white24,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLarge = false,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isLarge ? 24 : 16),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.white.withAlpha(5) : Colors.yellow,
          shape: BoxShape.circle,
          border: isSecondary ? Border.all(color: Colors.white10) : null,
          boxShadow: !isSecondary ? [
            BoxShadow(
              color: Colors.yellow.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Icon(
          icon,
          color: isSecondary ? Colors.white70 : Colors.black,
          size: isLarge ? 40 : 28,
        ),
      ),
    );
  }
}
