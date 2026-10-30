import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:table_calendar/table_calendar.dart';

enum _DayKind { completed, live, planned, empty }

class _DayEntry {
  const _DayEntry({required this.kind, this.workout});

  final _DayKind kind;
  final WorkoutSession? workout;
}

/// Week-at-a-glance calendar for the dashboard and the workouts list.
///
/// Built on `table_calendar` so week swiping, date maths and hit-testing come
/// from the package. Finished sessions show a check with the time trained and
/// the workout name, scheduled sessions show a plan badge and live sessions
/// are highlighted. Swipe or use the arrows to move between weeks; tapping a
/// day that has a session opens it when [onWorkoutTap] is provided.
class WorkoutWeekCalendar extends StatefulWidget {
  const WorkoutWeekCalendar({
    super.key,
    required this.workouts,
    this.onWorkoutTap,
  });

  final List<WorkoutSession> workouts;
  final ValueChanged<WorkoutSession>? onWorkoutTap;

  @override
  State<WorkoutWeekCalendar> createState() => _WorkoutWeekCalendarState();
}

class _WorkoutWeekCalendarState extends State<WorkoutWeekCalendar>
    with AutomaticKeepAliveClientMixin {
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  // The calendar sits inside lazy scroll views. Without this it is disposed
  // when scrolled off screen and rebuilds on the current week, losing the week
  // the user navigated to.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _focusedDay = today;
    _firstDay = DateTime(today.year - 5, today.month, today.day);
    _lastDay = DateTime(today.year + 5, today.month, today.day);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final monday = _startOfWeek(_focusedDay);
    final sunday = monday.add(const Duration(days: 6));
    final completed = List.generate(7, (i) {
      final entry = _entryFor(monday.add(Duration(days: i)));
      return entry.kind == _DayKind.completed ? 1 : 0;
    }).fold<int>(0, (sum, value) => sum + value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'WORKOUT CALENDAR',
                    style: text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _NavButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Previous week',
                  onTap: () => _shiftWeek(-1),
                ),
                const SizedBox(width: 6),
                _NavButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Next week',
                  onTap: () => _shiftWeek(1),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: 'Jump to a date',
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${DateFormatter.monthDay(monday)} – '
                                '${DateFormatter.monthDay(sunday)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleLarge,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!_isCurrentWeek) ...[
                  _TodayChip(onTap: _goToToday),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    '$completed done',
                    style: text.labelSmall!.copyWith(color: cs.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.1,
              child: TableCalendar<WorkoutSession>(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                availableCalendarFormats: const {CalendarFormat.week: 'Week'},
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekVisible: false,
                rowHeight: 108,
                pageAnimationDuration: const Duration(milliseconds: 220),
                pageAnimationCurve: Curves.easeOutCubic,
                availableGestures: AvailableGestures.horizontalSwipe,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  isTodayHighlighted: false,
                  cellMargin: EdgeInsets.zero,
                  cellPadding: EdgeInsets.zero,
                ),
                calendarBuilders: CalendarBuilders<WorkoutSession>(
                  prioritizedBuilder: (context, day, focusedDay) => _DayTile(
                    day: day,
                    entry: _entryFor(day),
                    isToday: _isSameDay(day, today),
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  final workout = _entryFor(selectedDay).workout;
                  if (workout != null) widget.onWorkoutTap?.call(workout);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isCurrentWeek =>
      _startOfWeek(_focusedDay) == _startOfWeek(DateTime.now());

  void _shiftWeek(int weeks) {
    final target = _focusedDay.add(Duration(days: 7 * weeks));
    if (target.isBefore(_firstDay) || target.isAfter(_lastDay)) return;
    setState(() => _focusedDay = target);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() => _focusedDay = DateTime(now.year, now.month, now.day));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: _firstDay,
      lastDate: _lastDay,
      helpText: 'Jump to a week',
    );
    if (picked == null || !mounted) return;
    setState(
      () => _focusedDay = DateTime(picked.year, picked.month, picked.day),
    );
  }

  List<WorkoutSession> _eventsForDay(DateTime day) {
    return widget.workouts.where((workout) {
      final date = _dateOf(workout);
      return date != null && _isSameDay(date, day);
    }).toList();
  }

  _DayEntry _entryFor(DateTime day) {
    WorkoutSession? completed;
    WorkoutSession? live;
    WorkoutSession? planned;

    for (final workout in _eventsForDay(day)) {
      switch (workout.status) {
        case SessionStatus.finished:
          completed ??= workout;
        case SessionStatus.inProgress:
        case SessionStatus.paused:
          live ??= workout;
        case SessionStatus.planned:
          planned ??= workout;
        case SessionStatus.cancelled:
          break;
      }
    }

    if (completed != null) {
      return _DayEntry(kind: _DayKind.completed, workout: completed);
    }
    if (live != null) return _DayEntry(kind: _DayKind.live, workout: live);
    if (planned != null) {
      return _DayEntry(kind: _DayKind.planned, workout: planned);
    }
    return const _DayEntry(kind: _DayKind.empty);
  }

  DateTime? _dateOf(WorkoutSession workout) {
    switch (workout.status) {
      case SessionStatus.finished:
        return workout.endedAt ?? workout.startedAt ?? workout.scheduledFor;
      case SessionStatus.inProgress:
      case SessionStatus.paused:
        return workout.startedAt ?? workout.createdAt;
      case SessionStatus.planned:
        return workout.scheduledFor ?? workout.createdAt;
      case SessionStatus.cancelled:
        return null;
    }
  }

  DateTime _startOfWeek(DateTime value) {
    final day = DateTime(value.year, value.month, value.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.entry,
    required this.isToday,
  });

  final DateTime day;
  final _DayEntry entry;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = _accent(cs);
    final minutes = _minutesTrained();
    final name = entry.workout?.name.trim() ?? '';
    final filled =
        entry.kind == _DayKind.completed || entry.kind == _DayKind.live;

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 1),
      decoration: BoxDecoration(
        color: isToday ? cs.primaryContainer.withValues(alpha: 0.35) : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? cs.primary : cs.outlineVariant,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormatter.weekday(day).substring(0, 1).toUpperCase(),
            style: text.labelSmall!.copyWith(
              color: isToday ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? accent : Colors.transparent,
              border: filled
                  ? null
                  : Border.all(
                      color: entry.kind == _DayKind.empty
                          ? cs.outlineVariant
                          : accent,
                    ),
            ),
            child: Icon(_icon, size: 15, color: filled ? cs.onPrimary : accent),
          ),
          const SizedBox(height: 5),
          Text(
            _label(minutes),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall!.copyWith(
              color: filled || entry.kind == _DayKind.planned
                  ? cs.onSurface
                  : cs.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: text.labelSmall!.copyWith(
                fontSize: 9,
                height: 1.15,
                letterSpacing: 0,
                color: isToday ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData get _icon => switch (entry.kind) {
    _DayKind.completed => Icons.check,
    _DayKind.live => Icons.play_arrow,
    _DayKind.planned => Icons.schedule,
    _DayKind.empty => Icons.remove,
  };

  Color _accent(ColorScheme cs) => switch (entry.kind) {
    _DayKind.completed || _DayKind.live => cs.primary,
    _DayKind.planned => cs.secondary,
    _DayKind.empty => cs.onSurfaceVariant,
  };

  String _label(int? minutes) => switch (entry.kind) {
    _DayKind.completed => minutes == null ? 'DONE' : '${minutes}m',
    _DayKind.live => 'LIVE',
    _DayKind.planned => 'PLAN',
    _DayKind.empty => '—',
  };

  int? _minutesTrained() {
    final workout = entry.workout;
    if (workout == null) return null;
    final startedAt = workout.startedAt;
    final endedAt = workout.endedAt;
    if (startedAt == null || endedAt == null) return null;
    final minutes = endedAt.difference(startedAt).inMinutes;
    return minutes > 0 ? minutes : null;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(icon, size: 18, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.6)),
        ),
        child: Text(
          'TODAY',
          style: text.labelSmall!.copyWith(color: cs.primary),
        ),
      ),
    );
  }
}
