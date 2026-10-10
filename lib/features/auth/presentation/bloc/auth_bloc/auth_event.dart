part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class SessionRestoreRequested extends AuthEvent {}

final class SignUpSubmitted extends AuthEvent {
  SignUpParams signUpParams;
  SignUpSubmitted({required this.signUpParams});
}

final class SignInSubmitted extends AuthEvent {
  SignInParams signInParams;
  SignInSubmitted({required this.signInParams});
}

final class PasswordResetRequested extends AuthEvent {
  ResetParams resetParams;
  PasswordResetRequested({required this.resetParams});
}

final class SignOutRequested extends AuthEvent {}

final class AccountDeletionRequested extends AuthEvent {}

final class VerificationEmailRequested extends AuthEvent {}

final class VerificationCheckRequested extends AuthEvent {}
