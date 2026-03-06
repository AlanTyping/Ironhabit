import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/habit_entity.dart';

class HabitTile extends StatelessWidget {
  final HabitEntity habit;
  final bool isCompleted;
  final bool isToday;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isToday,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted 
            ? [Colors.yellow.withAlpha(40), const Color(0xFF3D0F0F)]
            : [const Color(0xFF4D1515), const Color(0xFF3D0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted ? Colors.yellow.withAlpha(100) : Colors.white10,
          width: 1.5,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: Colors.yellow.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barra lateral de tiempo
              Container(
                width: 6,
                color: isCompleted ? Colors.yellow : Colors.white24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.yellow : Colors.white,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Colors.yellow.withAlpha(150),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 14, color: isCompleted ? Colors.yellow.withAlpha(150) : Colors.white38),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.startTime} - ${habit.endTime}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: isCompleted ? Colors.yellow.withAlpha(150) : Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isToday)
                        GestureDetector(
                          onTap: onToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.yellow : Colors.white.withAlpha(10),
                              shape: BoxShape.circle,
                              boxShadow: isCompleted ? [
                                BoxShadow(color: Colors.yellow.withAlpha(100), blurRadius: 10)
                              ] : [],
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.circle_outlined,
                              color: isCompleted ? const Color(0xFF2D0A0A) : Colors.white24,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
