import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/habit_entity.dart';
import 'habit_tile.dart';

class SlidableHabitTile extends StatefulWidget {
  final HabitEntity habit;
  final bool isCompleted;
  final bool isToday;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const SlidableHabitTile({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isToday,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<SlidableHabitTile> createState() => _SlidableHabitTileState();
}

class _SlidableHabitTileState extends State<SlidableHabitTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0;
  final double _deleteBtnWidth = 80;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      if (_dragExtent > 0) _dragExtent = 0;
      if (_dragExtent < -_deleteBtnWidth * 1.5) _dragExtent = -_deleteBtnWidth * 1.5;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent < -_deleteBtnWidth / 2) {
      _controller.animateTo(1.0);
      setState(() {
        _dragExtent = -_deleteBtnWidth;
      });
    } else {
      _controller.animateTo(0.0);
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botón de eliminar (debajo) - Solo visible si hay desplazamiento
        if (_dragExtent != 0)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withAlpha(150),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      width: _deleteBtnWidth,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // HabitTile (arriba)
        GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: HabitTile(
              habit: widget.habit,
              isCompleted: widget.isCompleted,
              isToday: widget.isToday,
              onToggle: widget.onToggle,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
