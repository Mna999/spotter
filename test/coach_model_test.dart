import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotter/features/workouts/domain/entities/cue_text.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/entities/planned_exercise.dart';
import 'package:spotter/features/workouts/presentation/screens/coach_model_screen.dart';
import 'package:spotter/features/workouts/presentation/widgets/planned_exercise_card.dart';

Exercise _squat({bool withCues = true}) {
  return Exercise(
    exerciseId: 'squat',
    nameAr: 'سكوات بالبار',
    nameEn: 'Barbell Back Squat',
    cues: withCues
        ? const {
            'good_rep': CueText(ar: 'تمرين جيد', en: 'Good rep, keep going'),
            'depth_low': CueText(ar: 'انزل أعمق', en: 'Go a bit deeper'),
          }
        : null,
    repThresholds: const {
      'primaryAngle': 'knee',
      'lowerDeg': 95,
      'upperDeg': 165,
      'smoothing': 'per-frame 0.7 old + 0.3 new',
      'depthClasses': {
        'partial': {'maxKneeAngleDeg': 130, 'countsAsRep': true},
        'deep': {'maxKneeAngleDeg': 110},
        'extraDeep': {'maxKneeAngleDeg': 95},
      },
    },
    schemaVersion: 1,
    createdAt: DateTime(2024),
  );
}

PlannedExercise _planned() {
  return PlannedExercise(
    plannedExerciseId: 'pe1',
    workoutId: 'w1',
    uid: 'u1',
    exerciseId: 'squat',
    order: 1,
    targetSets: 3,
    targetReps: 8,
    targetLoad: 60,
    targetTempo: '3-1-1',
    restSec: 90,
    schemaVersion: 1,
    createdAt: DateTime(2024),
  );
}

void main() {
  testWidgets('coach screen lays out nested thresholds without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: CoachModelScreen(exercise: _squat())),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('DEPTH CLASSES'), findsOneWidget);
    expect(find.text('MAX KNEE ANGLE DEG'), findsNWidgets(3));
    expect(find.text('COUNTS AS REP'), findsOneWidget);
  });

  testWidgets('planned card hides coach button when the model is missing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlannedExerciseCard(
            plannedExercise: _planned(),
            index: 0,
            exercise: _squat(withCues: false),
            onCoachTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('USE COACH MODEL'), findsNothing);
    expect(find.text('Coach model unavailable'), findsNothing);
  });
}
