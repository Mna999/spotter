part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  final BodyMetrics bodyMetrics;

  const ProfileLoaded({required this.userProfile, required this.bodyMetrics});

  @override
  List<Object?> get props => [userProfile, bodyMetrics];
}

final class OnBoardingNotCompleted extends ProfileState {}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
