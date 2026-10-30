import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotter/core/theme/app_theme.dart';
import 'package:spotter/features/workouts/domain/entities/session_status.dart';
import 'package:spotter/features/workouts/domain/entities/workout_session.dart';
import 'package:spotter/features/workouts/presentation/widgets/workout_week_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

WorkoutSession _session({
  required SessionStatus status,
  required DateTime createdAt,
  String id = 'w1',
  String name = 'Push day',
}) {
  return WorkoutSession(
    workoutId: id,
    uid: 'u1',
    name: name,
    status: status,
    schemaVersion: 1,
    createdAt: createdAt,
  );
}

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('renders an empty week without errors', (tester) async {
    await tester.pumpWidget(_host(const WorkoutWeekCalendar(workouts: [])));

    expect(find.text('WORKOUT CALENDAR'), findsOneWidget);
    expect(find.text('0 done'), findsOneWidget);
    expect(find.byTooltip('Next week'), findsOneWidget);
    expect(find.byTooltip('Previous week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows minutes and name for a finished workout, opens on tap', (
    tester,
  ) async {
    final now = DateTime.now();
    final workout = _session(status: SessionStatus.finished, createdAt: now)
      ..startedAt = now.subtract(const Duration(minutes: 65))
      ..endedAt = now;

    WorkoutSession? opened;
    await tester.pumpWidget(
      _host(
        WorkoutWeekCalendar(
          workouts: [workout],
          onWorkoutTap: (value) => opened = value,
        ),
      ),
    );

    expect(find.text('1 done'), findsOneWidget);
    expect(find.text('65m'), findsOneWidget);
    expect(find.text('Push day'), findsOneWidget);

    await tester.tap(find.text('65m'));
    await tester.pumpAndSettle();

    expect(opened, workout);
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks a scheduled workout as a plan', (tester) async {
    final now = DateTime.now();
    // Keep the scheduled date inside the visible week (Monday to Sunday) so the
    // test does not depend on which weekday it happens to run.
    final daysUntilSunday = DateTime.daysPerWeek - now.weekday;
    final planned = _session(
      status: SessionStatus.planned,
      createdAt: now,
      id: 'w2',
    )..scheduledFor = now.add(Duration(days: daysUntilSunday));

    await tester.pumpWidget(_host(WorkoutWeekCalendar(workouts: [planned])));

    expect(find.text('PLAN'), findsOneWidget);
    expect(find.text('Push day'), findsOneWidget);
    expect(find.text('0 done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrows reach past and future weeks and return to today', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final done =
        _session(
            status: SessionStatus.finished,
            createdAt: lastWeek,
            id: 'w3',
            name: 'Pull day',
          )
          ..startedAt = lastWeek.subtract(const Duration(minutes: 40))
          ..endedAt = lastWeek;
    final planned = _session(
      status: SessionStatus.planned,
      createdAt: now,
      id: 'w4',
      name: 'Leg day',
    )..scheduledFor = now.add(const Duration(days: 7));

    await tester.pumpWidget(
      _host(WorkoutWeekCalendar(workouts: [done, planned])),
    );

    expect(find.text('Pull day'), findsNothing);
    expect(find.text('Leg day'), findsNothing);
    expect(find.text('TODAY'), findsNothing);

    await tester.tap(find.byTooltip('Previous week'));
    await tester.pumpAndSettle();

    expect(find.text('Pull day'), findsOneWidget);
    expect(find.text('40m'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();

    expect(find.text('Pull day'), findsNothing);
    expect(find.text('TODAY'), findsNothing);

    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();

    expect(find.text('PLAN'), findsOneWidget);
    expect(find.text('Leg day'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('TODAY'));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsNothing);
    expect(find.text('TODAY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('range label opens a date picker to jump weeks', (tester) async {
    await tester.pumpWidget(_host(const WorkoutWeekCalendar(workouts: [])));

    await tester.tap(find.textContaining('–'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping also moves between weeks', (tester) async {
    await tester.pumpWidget(_host(const WorkoutWeekCalendar(workouts: [])));

    final rangeFinder = find.textContaining('–');
    final initialRange = tester.widget<Text>(rangeFinder).data;

    await tester.drag(
      find.byType(TableCalendar<WorkoutSession>),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    final shiftedRange = tester.widget<Text>(rangeFinder).data;
    expect(shiftedRange, isNot(initialRange));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the selected week when scrolled out of view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ListView(
            children: const [
              WorkoutWeekCalendar(workouts: []),
              SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Next week'));
    await tester.pumpAndSettle();
    final shiftedRange = tester.widget<Text>(find.textContaining('–')).data;

    // Scroll the calendar far out of the viewport and back. A lazy list would
    // dispose it here and it would reopen on the current week.
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 1200));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.textContaining('–')).data, shiftedRange);
    expect(tester.takeException(), isNull);
  });
}
