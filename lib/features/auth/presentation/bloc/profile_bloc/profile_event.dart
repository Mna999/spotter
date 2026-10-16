part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  final ProfileParams profileParams;

  const ProfileLoadRequested({required this.profileParams});

  @override
  List<Object> get props => [profileParams];
}

final class BodyStatsUpdated extends ProfileEvent {
  final UserProfile profile;

  const BodyStatsUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}

final class WeeklyTargetChanged extends ProfileEvent {
  final TargetParams params;

  const WeeklyTargetChanged({required this.params});

  @override
  List<Object> get props => [params];
}
