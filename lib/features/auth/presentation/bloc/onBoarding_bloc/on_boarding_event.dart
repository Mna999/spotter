part of 'on_boarding_bloc.dart';

sealed class OnBoardingEvent extends Equatable {
  const OnBoardingEvent();

  @override
  List<Object> get props => [];
}

class OnBoardingSubmitted extends OnBoardingEvent {
  OnboardingParams onboardingParams;
  OnBoardingSubmitted({required this.onboardingParams});
  @override
  List<Object> get props => [onboardingParams];
}
