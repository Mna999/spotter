import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotter/features/workouts/domain/params/rest_params.dart';
import 'package:spotter/features/workouts/domain/usecases/start_rest_timer_usecase.dart';
import 'package:spotter/features/workouts/presentation/widgets/rest_timer_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('rest countdown stream ticks once per second down to zero', () async {
    final ticks = <Duration>[];
    await for (final result in const StartRestTimerUseCase()(
      const RestParams(durationSec: 2),
    )) {
      result.fold((failure) => fail(failure.message), ticks.add);
    }

    expect(ticks, const [
      Duration(seconds: 2),
      Duration(seconds: 1),
      Duration.zero,
    ]);
  });

  testWidgets('rest timer shows minutes and seconds, not hours and minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RestTimerCard(
          remaining: const Duration(seconds: 89),
          total: const Duration(seconds: 90),
          onSkip: () {},
        ),
      ),
    );

    expect(find.text('01:29'), findsOneWidget);
    expect(find.text('OF 01:30'), findsOneWidget);
  });

  testWidgets('rest timer keeps the total while the last minute runs', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RestTimerCard(
          remaining: const Duration(seconds: 1),
          total: const Duration(seconds: 90),
          onSkip: () {},
        ),
      ),
    );

    expect(find.text('00:01'), findsOneWidget);
    expect(find.text('OF 01:30'), findsOneWidget);
  });
}
