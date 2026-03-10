import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/pomodoro_stats_bloc.dart';
import '../bloc/pomodoro_stats_event.dart';
import '../bloc/pomodoro_stats_state.dart';

class PomodoroStatsPage extends StatelessWidget {
  const PomodoroStatsPage({super.key});

  String _formatHours(int seconds) {
    final double hours = seconds / 3600;
    return hours.toStringAsFixed(1);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0505),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Historial de Enfoque',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1A0505),
      body: BlocBuilder<PomodoroStatsBloc, PomodoroStatsState>(
        builder: (context, state) {
          if (state is PomodoroStatsLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }

          if (state is PomodoroStatsLoaded) {
            final DateTime monday = state.weekStartDate;
            final DateTime sunday = monday.add(const Duration(days: 6));
            final String weekRange = "${DateFormat('dd MMM').format(monday)} - ${DateFormat('dd MMM').format(sunday)}";

            int maxSeconds = state.weeklyStats.values.fold(0, (max, val) => val > max ? val : max);
            if (maxSeconds == 0) maxSeconds = 3600;

            final int totalSeconds = state.weeklyStats.values.fold(0, (sum, val) => sum + val);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de Semana
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.read<PomodoroStatsBloc>().add(LoadWeeklyStats(monday.subtract(const Duration(days: 7)))),
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.yellow, size: 28),
                        ),
                        Expanded(
                          child: Text(
                            weekRange.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.read<PomodoroStatsBloc>().add(LoadWeeklyStats(monday.add(const Duration(days: 7)))),
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.yellow, size: 28),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Resumen Semanal
                  Text(
                    'TOTAL SEMANAL',
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  Text(
                    _formatTime(totalSeconds),
                    style: GoogleFonts.outfit(color: Colors.yellow, fontSize: 44, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40),

                  // Gráfico de Barras con Expanded para evitar overflows
                  Container(
                    height: 220,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final date = monday.add(Duration(days: index));
                        final seconds = state.weeklyStats[date] ?? 0;
                        final double barHeight = (seconds / maxSeconds) * 140;
                        final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _formatHours(seconds),
                                style: GoogleFonts.outfit(
                                  color: seconds > 0 ? Colors.white70 : Colors.transparent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: double.infinity,
                                height: barHeight.clamp(4, 140),
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.yellow : Colors.yellow.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isToday ? [
                                    BoxShadow(color: Colors.yellow.withAlpha(40), blurRadius: 8)
                                  ] : [],
                                ),
                              ).animate().scaleY(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
                              const SizedBox(height: 10),
                              Text(
                                DateFormat('E').format(date).substring(0, 1).toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: isToday ? Colors.yellow : Colors.white24,
                                  fontSize: 12,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Lista Detallada
                  Text(
                    'DETALLES DIARIOS',
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 16),
                  
                  if (totalSeconds == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'Sin actividad esta semana',
                          style: GoogleFonts.outfit(color: Colors.white10, fontSize: 16),
                        ),
                      ),
                    ),

                  ...List.generate(7, (index) {
                    final date = monday.add(Duration(days: index));
                    final seconds = state.weeklyStats[date] ?? 0;
                    if (seconds == 0) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, dd MMMM').format(date),
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15),
                            ),
                          ),
                          Text(
                            _formatTime(seconds),
                            style: GoogleFonts.outfit(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                  }),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
