part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  UserAccount userAccount;
  Authenticated({required this.userAccount});
  @override
  List<Object> get props => [userAccount];
}

final class UnAuthenticated extends AuthState {}

final class PasswordResetSent extends AuthState {}

final class AuthError extends AuthState {
  String message;

  AuthError({required this.message});
}

final class VerificationEmailSent extends AuthState {}

final class EmailVerified extends AuthState {}

final class EmailNotVerified extends AuthState {}
