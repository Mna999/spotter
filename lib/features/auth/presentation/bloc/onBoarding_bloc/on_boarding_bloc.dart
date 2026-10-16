import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/usecases/complete_on_boarding_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/compute_body_metrics_usecase.dart';

part 'on_boarding_event.dart';
part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  CompleteOnBoardingUseCase completeOnBoardingUseCase;
  ComputeBodyMetricsUseCase computeBodyMetricsUseCase;
  OnBoardingBloc({
    required this.completeOnBoardingUseCase,
    required this.computeBodyMetricsUseCase,
  }) : super(const OnBoardingEditing(step: 0)) {
    on<OnBoardingSubmitted>((event, emit) async {
      final res = await completeOnBoardingUseCase(event.onboardingParams);
      res.fold((failure) => emit(OnBoardingError(message: failure.message)), (
        profile,
      ) async {
        emit(OnBoardingSubmitting());
        final res = await computeBodyMetricsUseCase(
          MetricsParams.fromProfile(profile),
        );
        res.fold(
          (failure) => emit(OnBoardingError(message: failure.message)),
          (metrics) => emit(
            OnBoardingCompleted(bodyMetrics: metrics, userProfile: profile),
          ),
        );
      });
    });
  }
}
