import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/core/usecases/stream_usecase.dart';
import 'package:spotter/features/workouts/domain/params/rest_params.dart';

class StartRestTimerUseCase implements StreamUseCase<Duration, RestParams> {
  const StartRestTimerUseCase();

  @override
  Stream<Either<Failure, Duration>> call(RestParams params) async* {
    final totalSec = params.durationSec;
    if (totalSec < 0) {
      yield Left(
        ServerFailure(message: 'durationSec cannot be negative: $totalSec'),
      );
      return;
    }
    if (totalSec == 0) {
      yield const Right(Duration.zero);
      return;
    }

    for (var remaining = totalSec; remaining >= 0; remaining--) {
      yield Right(Duration(seconds: remaining));
      if (remaining > 0) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
}
