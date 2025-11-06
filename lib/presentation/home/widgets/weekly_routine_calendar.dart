import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/presentation/home/home_controller.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

typedef CalendarDayCallback = void Function(HomeCalendarDay day);

class WeeklyRoutineCalendar extends StatelessWidget {
  const WeeklyRoutineCalendar({
    super.key,
    required this.days,
    this.onDaySelected,
  });

  final List<HomeCalendarDay> days;
  final CalendarDayCallback? onDaySelected;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (context, index) {
          final HomeCalendarDay day = days[index];
          return _CalendarDayTile(day: day, onTap: onDaySelected);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: days.length,
      ),
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({required this.day, this.onTap});

  final HomeCalendarDay day;
  final CalendarDayCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasRoutine = day.hasRoutines;
    final bool completed = day.isCompleted;
    final bool isToday = _isSameDay(day.date, DateTime.now());
    final Color accent = completed
        ? AppColors.success
        : hasRoutine
        ? AppColors.accentBlue
        : AppColors.textSecondary;

    final Widget content = Container(
      width: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: hasRoutine
            ? accent.withValues(alpha: 0.12)
            : AppColors.veryLightGray,
        border: Border.all(
          color: isToday ? accent : AppColors.veryLightGray,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _dayLabel(day.date),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          Text(
            '${day.date.day}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          if (hasRoutine)
            Row(
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.fitness_center,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    day.scheduledRoutines.first.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              completed ? 'Completado' : 'Descanso',
              style: theme.textTheme.bodySmall?.copyWith(color: accent),
            ),
        ],
      ),
    );

    if (hasRoutine && onTap != null) {
      return GestureDetector(onTap: () => onTap!(day), child: content);
    }
    return content;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _dayLabel(DateTime date) {
    const List<String> labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final int index = (date.weekday - 1) % labels.length;
    return labels[index];
  }
}
