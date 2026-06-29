

import 'package:flutter/material.dart';
import 'package:flex_fit/Pages/Dashboard/model/workout_history_model.dart';
import 'package:flex_fit/Pages/Components/DashboardPageComponents/workout_history_card.dart';
import 'package:flex_fit/theme/app_colors.dart';

class WorkoutHistoryPage extends StatefulWidget {
  final List<WorkoutHistoryModel> history;

  const WorkoutHistoryPage({super.key, required this.history});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  /// Set of calendar-day DateTimes (year, month, day only) for quick lookup.
  late Set<DateTime> _workoutDays;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _workoutDays = widget.history
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
  }

  List<WorkoutHistoryModel> get _filteredHistory {
    if (_selectedDay == null) return widget.history;
    return widget.history.where((w) {
      final d = DateTime(w.date.year, w.date.month, w.date.day);
      return d == _selectedDay;
    }).toList();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (nextMonth.isAfter(DateTime(now.year, now.month + 1))) return;
    setState(() {
      _currentMonth = nextMonth;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHistory;

    return Scaffold(
      backgroundColor: context.pageBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.deepBg, context.pageBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: context.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Workout History',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.history.length} total',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Calendar ──
              _MonthCalendar(
                currentMonth: _currentMonth,
                selectedDay: _selectedDay,
                workoutDays: _workoutDays,
                onPrevMonth: _prevMonth,
                onNextMonth: _nextMonth,
                onDayTap: (day) {
                  setState(() {
                    if (_selectedDay == day) {
                      _selectedDay = null; // Toggle off
                    } else {
                      _selectedDay = day;
                    }
                  });
                },
              ),

              const SizedBox(height: 8),

              // ── Filter chip ──
              if (_selectedDay != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.accentBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.accentLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatSelectedDay(_selectedDay!),
                              style: TextStyle(
                                color: context.accentLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDay = null),
                              child: Icon(
                                Icons.close_rounded,
                                color: context.accentLight,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} workout${filtered.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              // ── Workout list ──
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              color: context.textMuted,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedDay != null
                                  ? 'No workouts on this day'
                                  : 'No workouts yet',
                              style: TextStyle(
                                color: context.textMuted,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return WorkoutHistoryCard(
                              workout: filtered[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSelectedDay(DateTime day) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom compact monthly calendar widget (no external dependencies)
// ─────────────────────────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDay;
  final Set<DateTime> workoutDays;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;

  const _MonthCalendar({
    required this.currentMonth,
    required this.selectedDay,
    required this.workoutDays,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday; // Mon=1 .. Sun=7
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Can't navigate past current month
    final now = DateTime.now();
    final canGoNext =
        DateTime(year, month + 1).isBefore(DateTime(now.year, now.month + 1));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border, width: 1),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          // ── Month nav row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onPrevMonth,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: context.accentLight,
                    size: 22,
                  ),
                ),
              ),
              Text(
                '${months[month - 1]} $year',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: canGoNext ? onNextMonth : null,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: canGoNext
                        ? context.accentBg
                        : context.accentBg.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: canGoNext
                        ? context.accentLight
                        : context.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Weekday headers ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (d) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: context.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // ── Day grid ──
          _buildDayGrid(
            context,
            daysInMonth,
            firstWeekday,
            todayDate,
            year,
            month,
          ),
        ],
      ),
    );
  }

  Widget _buildDayGrid(
    BuildContext context,
    int daysInMonth,
    int firstWeekday,
    DateTime todayDate,
    int year,
    int month,
  ) {
    // Build rows of 7 cells
    final rows = <Widget>[];
    // Number of rows needed
    final totalCells = (firstWeekday - 1) + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    for (int row = 0; row < rowCount; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        final dayIndex = cellIndex - (firstWeekday - 1) + 1;

        if (dayIndex < 1 || dayIndex > daysInMonth) {
          cells.add(const SizedBox(width: 36, height: 36));
          continue;
        }

        final date = DateTime(year, month, dayIndex);
        final isToday = date == todayDate;
        final hasWorkout = workoutDays.contains(date);
        final isSelected = selectedDay == date;
        final isFuture = date.isAfter(todayDate);

        cells.add(
          GestureDetector(
            onTap: isFuture ? null : () => onDayTap(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.accentLight
                    : isToday
                        ? context.accentBg
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$dayIndex',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isFuture
                              ? context.textHint
                              : isToday
                                  ? context.accentLight
                                  : context.textPrimary,
                      fontSize: 14,
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  // Workout dot indicator
                  if (hasWorkout && !isSelected)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: context.accentLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (hasWorkout && isSelected)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: cells,
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
