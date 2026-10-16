part of 'on_boarding_bloc.dart';

sealed class OnBoardingState extends Equatable {
  const OnBoardingState();

  @override
  List<Object> get props => [];
}

final class OnBoardingEditing extends OnBoardingState {
  final int step;
  const OnBoardingEditing({required this.step});
  @override
  List<Object> get props => [step];
}

final class OnBoardingSubmitting extends OnBoardingState {}

final class OnBoardingCompleted extends OnBoardingState {
  UserProfile userProfile;
  BodyMetrics bodyMetrics;

  OnBoardingCompleted({required this.bodyMetrics, required this.userProfile});
  @override
  List<Object> get props => [userProfile, bodyMetrics];
}

final class OnBoardingError extends OnBoardingState {
  String message;

  OnBoardingError({required this.message});
  @override
  List<Object> get props => [message];
}
