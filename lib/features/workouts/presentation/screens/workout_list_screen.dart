import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/app_dialog.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/presentation/blocs/workout_session_bloc/workout_session_bloc.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_form_sheet.dart';
import 'package:spotter/features/workouts/presentation/widgets/section_title.dart';
import 'package:spotter/features/workouts/presentation/widgets/workout_card.dart';
import 'package:spotter/features/workouts/presentation/widgets/workout_week_calendar.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  List<WorkoutSession> _lastWorkouts = const [];
  bool _openingDetail = false;
  String? _uid;

  String? _deletingId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) _uid = authState.userAccount.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final uid = _uid;
    if (uid == null) return;
    context.read<WorkoutSessionBloc>().add(LoadWorkouts(uid: uid));
  }

  Future<void> _openDetail(WorkoutSession workout) async {
    final uid = _uid;
    if (uid == null || _openingDetail) return;
    _openingDetail = true;
    await Routing.routePush(
      WorkoutDetailScreen(uid: uid, workoutId: workout.workoutId),
      context,
    );
    _openingDetail = false;
    if (!mounted) return;
    _load();
  }

  Future<void> _createWorkout() async {
    final uid = _uid;
    if (uid == null) return;
    final result = await showWorkoutFormSheet(
      context,
      title: 'NEW WORKOUT',
      confirmLabel: 'CREATE WORKOUT',
      name: 'Workout',
      scheduledFor: DateTime.now(),
      requireFuture: true,
    );
    if (result == null || !mounted) return;
    context.read<WorkoutSessionBloc>().add(
      WorkoutScheduled(
        uid: uid,
        name: result.name,
        scheduledFor: result.scheduledFor,
      ),
    );
  }

  void _deleteWorkout(WorkoutSession workout) {
    final uid = _uid;
    if (uid == null) return;
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete workout?'),
        content: const Text(
          'This permanently deletes the workout and every set logged in it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted) return;
              setState(() => _deletingId = workout.workoutId);
              final bloc = context.read<WorkoutSessionBloc>();
              bloc.add(WorkoutDeleted(uid: uid, workoutId: workout.workoutId));
              bloc.add(LoadWorkouts(uid: uid));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts', style: text.headlineMedium),
        actions: [
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _createWorkout,
            tooltip: 'New workout',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          if (state is WorkoutsLoaded) {
            final deletingId = _deletingId;
            _lastWorkouts = deletingId == null
                ? state.workoutSessions
                : state.workoutSessions
                      .where((session) => session.workoutId != deletingId)
                      .toList();
            if (_deletingId != null) setState(() => _deletingId = null);
          }
          if (state is WorkoutError) {
            if (_deletingId != null) setState(() => _deletingId = null);
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);
          }
          if (state is WorkoutEmpty && _deletingId != null) {
            // The delete finished: drop it from the cached list right away so
            // the screen cannot fall back to "No workouts yet" while the list
            // refresh is still on its way.
            final deletingId = _deletingId;
            final remaining = _lastWorkouts
                .where((session) => session.workoutId != deletingId)
                .toList();
            if (remaining.isNotEmpty) {
              // Still has workouts to show: stop the delete spinner and render
              // the updated list. When nothing is left, keep spinning until the
              // refresh confirms the list really is empty.
              setState(() {
                _lastWorkouts = remaining;
                _deletingId = null;
              });
            }
          } else if (state is WorkoutLoaded) {
            _openDetail(state.workoutSession);
          }
        },
        builder: (context, state) {
          if (_deletingId != null) {
            return const Center(child: CircularProgressIndicator());
          }
          // Keep the cached list on screen while a refresh is in flight so the
          // calendar keeps the week the user navigated to (and the list does
          // not flash a full-screen spinner on every reload).
          if (state is WorkoutLoading && _lastWorkouts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WorkoutError) {
            return _messageView(
              context,
              title: 'Could not load workouts',
              message: state.message,
              isError: true,
              onRetry: _load,
            );
          }
          if (state is WorkoutEmpty && _lastWorkouts.isEmpty) {
            return _messageView(
              context,
              title: 'No workouts yet',
              message: 'Create a workout to start planning your routine.',
              onRetry: _createWorkout,
              retryLabel: 'NEW WORKOUT',
            );
          }

          final workouts = _lastWorkouts;

          if (workouts.isEmpty) {
            return _messageView(
              context,
              title: 'No workouts yet',
              message: 'Create a workout to start planning your routine.',
              onRetry: _createWorkout,
              retryLabel: 'NEW WORKOUT',
            );
          }

          final active = workouts.where(
            (w) =>
                w.status == SessionStatus.inProgress ||
                w.status == SessionStatus.paused,
          );
          final planned = workouts.where(
            (w) => w.status == SessionStatus.planned,
          );
          final history = workouts.where(
            (w) =>
                w.status == SessionStatus.finished ||
                w.status == SessionStatus.cancelled,
          );

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                WorkoutWeekCalendar(
                  workouts: workouts,
                  onWorkoutTap: _openDetail,
                ),
                const SizedBox(height: 16),
                if (active.isNotEmpty) ...[
                  const SectionTitle(title: 'CONTINUE TRAINING'),
                  const SizedBox(height: 8),
                  for (final workout in active)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutCard(
                        workout: workout,
                        onTap: () => _openDetail(workout),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                if (planned.isNotEmpty) ...[
                  const SectionTitle(title: 'SCHEDULED'),
                  const SizedBox(height: 8),
                  for (final workout in planned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutCard(
                        workout: workout,
                        onTap: () => _openDetail(workout),
                        onDelete: () => _deleteWorkout(workout),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                if (history.isNotEmpty) ...[
                  const SectionTitle(title: 'HISTORY'),
                  const SizedBox(height: 8),
                  for (final workout in history)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutCard(
                        workout: workout,
                        onTap: () => _openDetail(workout),
                        onDelete: () => _deleteWorkout(workout),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _createWorkout,
                    icon: const Icon(Icons.add),
                    label: const Text('NEW WORKOUT'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _messageView(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onRetry,
    String retryLabel = 'RETRY',
  }) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.fitness_center,
              size: 44,
              color: isError ? cs.error : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(title, style: text.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall!.copyWith(
                color: isError ? cs.error : cs.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
