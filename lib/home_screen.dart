import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/date_formatter.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:spotter/features/auth/presentation/widgets/macro_goals_card.dart';
import 'package:spotter/features/auth/presentation/widgets/spotter_title.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/features/workouts/presentation/widgets/workout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenWorkouts});

  /// Called when the dashboard wants to hand the user over to the workout tab
  /// (for example from the "see all" / "plan a workout" actions).
  final VoidCallback? onOpenWorkouts;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WorkoutSession> _workouts = const [];
  String? _uid;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) _uid = authState.userAccount.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  void _load() {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _loading = true);
    context.read<WorkoutSessionBloc>().add(LoadWorkouts(uid: uid));
  }

  Future<void> _openDetail(WorkoutSession workout) async {
    final uid = _uid;
    if (uid == null) return;
    await Routing.routePush(
      WorkoutDetailScreen(uid: uid, workoutId: workout.workoutId),
      context,
    );
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const SpotterTitle(),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh dashboard',
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          if (state is WorkoutsLoaded) {
            _workouts = state.workoutSessions;
            if (_loading) setState(() => _loading = false);
          }
          if (state is WorkoutError && _loading) {
            setState(() => _loading = false);
          }
          // A session just ended: pull a fresh history for the dashboard.
          if (state is WorkoutFinished) {
            _load();
          }
        },
        builder: (context, state) {
          final workouts = state is WorkoutsLoaded
              ? state.workoutSessions
              : _workouts;
          final profileState = context.watch<ProfileBloc>().state;
          final profile = profileState is ProfileLoaded
              ? profileState.userProfile
              : null;
          final metrics = profileState is ProfileLoaded
              ? profileState.bodyMetrics
              : null;

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const _GreetingHeader(),
                const SizedBox(height: 16),
                _WorkoutHero(
                  workout: _nextWorkout(workouts),
                  onOpen: (workout) => _openDetail(workout),
                  onPlan: widget.onOpenWorkouts,
                ),
                if (metrics != null && profile != null) ...[
                  const SizedBox(height: 16),
                  MacroGoalsCard(
                    macroTargets: metrics.macroTargets,
                    tdee: metrics.tdee,
                    bmi: metrics.bmi,
                    goal: profile.goal,
                  ),
                ],
                if (profile != null) ...[
                  const SizedBox(height: 16),
                  _WeeklyTargetCard(
                    weeklyTargetMin: profile.weeklyTargetMin,
                    trainingDays: profile.trainingDays,
                    workouts: workouts,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: SectionTitle(title: 'RECENT ACTIVITY'),
                    ),
                    if (widget.onOpenWorkouts != null)
                      TextButton(
                        onPressed: widget.onOpenWorkouts,
                        child: Text(
                          'SEE ALL',
                          style: text.labelSmall!.copyWith(color: cs.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _recentActivity(text, cs, workouts),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _recentActivity(
    TextTheme text,
    ColorScheme cs,
    List<WorkoutSession> workouts,
  ) {
    final history =
        workouts
            .where(
              (w) =>
                  w.status == SessionStatus.finished ||
                  w.status == SessionStatus.cancelled,
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.endedAt ?? a.startedAt ?? a.createdAt;
            final bDate = b.endedAt ?? b.startedAt ?? b.createdAt;
            return bDate.compareTo(aDate);
          });
    final recent = history.take(3).toList();

    if (recent.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.history_toggle_off,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No sessions logged yet. Your finished workouts will appear '
                  'here.',
                  style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final workout in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WorkoutCard(
              workout: workout,
              onTap: () => _openDetail(workout),
            ),
          ),
      ],
    );
  }

  WorkoutSession? _nextWorkout(List<WorkoutSession> workouts) {
    for (final workout in workouts) {
      if (workout.status == SessionStatus.inProgress ||
          workout.status == SessionStatus.paused) {
        return workout;
      }
    }
    for (final workout in workouts) {
      if (workout.status == SessionStatus.planned) return workout;
    }
    return null;
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final displayName = authState is Authenticated
        ? authState.userAccount.displayName
        : 'Athlete';
    final firstName = displayName.trim().isEmpty
        ? 'Athlete'
        : displayName.trim().split(RegExp(r'\s+')).first;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _greeting(now),
                style: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                '${DateFormatter.weekday(now).substring(0, 3).toUpperCase()} · '
                '${DateFormatter.date(now)}',
                style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text('$firstName, ready to move?', style: text.headlineLarge),
      ],
    );
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({
    required this.workout,
    required this.onOpen,
    this.onPlan,
  });

  final WorkoutSession? workout;
  final ValueChanged<WorkoutSession> onOpen;
  final VoidCallback? onPlan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final current = workout;
    final isLive =
        current != null &&
        (current.status == SessionStatus.inProgress ||
            current.status == SessionStatus.paused);

    final label = current == null
        ? 'NO SESSION SCHEDULED'
        : isLive
        ? 'CONTINUE TRAINING'
        : 'SCHEDULED ROUTINE';
    final title = current == null
        ? 'Build your next routine'
        : isLive
        ? 'Workout in progress'
        : 'Workout ready to start';
    final subtitle = current == null
        ? 'Pick exercises, set your targets, then start training with live '
              'coaching.'
        : isLive
        ? 'Resume where you left off and keep the momentum going.'
        : 'Scheduled ${DateFormatter.dateTime(current.scheduledFor ?? current.createdAt)}';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLive ? cs.primary : cs.outlineVariant,
          width: isLive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLive ? cs.primary : cs.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: text.labelSmall!.copyWith(
                      color: isLive ? cs.primary : cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (current != null)
                  Text(
                    DateFormatter.date(current.startedAt ?? current.createdAt),
                    style: text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: text.headlineMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (current != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onOpen(current),
                  icon: Icon(isLive ? Icons.play_arrow : Icons.fitness_center),
                  label: Text(isLive ? 'RESUME WORKOUT' : 'START WORKOUT'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPlan,
                  icon: const Icon(Icons.add),
                  label: const Text('PLAN A WORKOUT'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTargetCard extends StatelessWidget {
  const _WeeklyTargetCard({
    required this.weeklyTargetMin,
    required this.trainingDays,
    required this.workouts,
  });

  final int weeklyTargetMin;
  final int trainingDays;
  final List<WorkoutSession> workouts;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final completedMin = _completedMinutesThisWeek();
    final target = weeklyTargetMin <= 0 ? 1 : weeklyTargetMin;
    final progress = (completedMin / target).clamp(0.0, 1.0);
    final remaining = (target - completedMin).clamp(0, target);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY TARGET',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$weeklyTargetMin min active',
                        style: text.titleLarge,
                      ),
                    ],
                  ),
                ),
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
                    '$trainingDays days / week',
                    style: text.labelSmall!.copyWith(color: cs.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainer,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$completedMin min completed',
                    style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Text(
                  remaining == 0 ? 'TARGET HIT' : '$remaining min to go',
                  style: text.labelSmall!.copyWith(
                    color: remaining == 0 ? cs.primary : cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _completedMinutesThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    var minutes = 0;
    for (final workout in workouts) {
      if (workout.status != SessionStatus.finished) continue;
      final endedAt = workout.endedAt;
      if (endedAt == null || endedAt.isBefore(startOfWeek)) continue;
      final startedAt = workout.startedAt;
      if (startedAt == null) continue;
      minutes += endedAt.difference(startedAt).inMinutes;
    }
    return minutes;
  }
}
