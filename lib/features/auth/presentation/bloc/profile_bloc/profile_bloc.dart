import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/body_metrics.dart';
import 'package:spotter/features/auth/domain/entities/user_profile.dart';
import 'package:spotter/features/auth/domain/usecases/compute_body_metrics_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/get_user_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ComputeBodyMetricsUseCase computeBodyMetricsUseCase;
  //UpdateWeeklyTargetUseCase updateWeeklyTargetUseCase;
  GetUserProfileUseCase getUserProfileUseCase;
  ProfileBloc({
    required this.computeBodyMetricsUseCase,
    //required this.updateWeeklyTargetUseCase,
    required this.getUserProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>((event, emit) async {
      emit(const ProfileLoading());
      final res = await getUserProfileUseCase(event.profileParams);
      debugPrint('profile result: $res');
      res.fold((failure) => emit(ProfileError(message: failure.message)), (
        profile,
      ) {
        if (profile == null)
          emit(OnBoardingNotCompleted());
        else
          emit(
            ProfileLoaded(
              userProfile: profile,
              bodyMetrics: BodyMetrics.fromProfile(profile),
            ),
          );
      });
    });

    on<BodyStatsUpdated>((event, emit) async {
      final previous = state;
      emit(const ProfileLoading());
      final res = await computeBodyMetricsUseCase(
        MetricsParams.fromProfile(event.profile),
      );
      res.fold(
        (failure) {
          emit(ProfileError(message: failure.message));
          emit(previous);
        },
        (metrics) =>
            ProfileLoaded(userProfile: event.profile, bodyMetrics: metrics),
      );
    });

    /*  on<WeeklyTargetChanged>((event, emit) async {
      final previous = state;
      if (previous is! ProfileLoaded) return;
      emit(const ProfileLoading());
      final res = await updateWeeklyTargetUseCase(event.params);
      res.fold(
        (failure) {
          emit(ProfileError(message: failure.message));
          emit(previous);
        },
        (_) => emit(
          ProfileLoaded(
            userProfile: previous.userProfile.copyWith(
              weeklyTargetMin: event.params.minutes,
              trainingDays: event.params.strengthDays,
            ),
            bodyMetrics: previous.bodyMetrics,
          ),
        ),
      );
    }); */
  }
}
