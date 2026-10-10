import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/domain/entities/user_account.dart';
import 'package:spotter/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:spotter/features/auth/domain/usecases/sign_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  SignUpUseCase signUpUseCase;
  SignInUseCase signInUseCase;
  ResetPasswordUseCase resetPasswordUseCase;
  RestoreSessionUseCase restoreSessionUseCase;
  SignOutUseCase signOutUseCase;
  DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.deleteAccountUseCase,
    required this.resetPasswordUseCase,
    required this.restoreSessionUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.signUpUseCase,
  }) : super(AuthInitial()) {
    on<SessionRestoreRequested>((event, emit) async {
      emit(AuthLoading());
      final res = await restoreSessionUseCase(NoParams());
      res.fold((failure) => emit(AuthError(message: failure.message)), (user) {
        if (user == null)
          emit(UnAuthenticated());
        else
          emit(Authenticated(userAccount: user));
      });
    });

    on<SignUpSubmitted>((event, emit) async {
      emit(AuthLoading());
      final res = await signUpUseCase(event.signUpParams);
      res.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(Authenticated(userAccount: user)),
      );
    });

    on<SignInSubmitted>((event, emit) async {
      emit(AuthLoading());
      final res = await signInUseCase(event.signInParams);
      res.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(Authenticated(userAccount: user)),
      );
    });

    on<PasswordResetRequested>((event, emit) async {
      emit(AuthLoading());
      final res = await resetPasswordUseCase(event.resetParams);
      res.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) => emit(UnAuthenticated()),
      );
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      final res = await signOutUseCase(NoParams());
      res.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) => emit(UnAuthenticated()),
      );
    });

    on<AccountDeletionRequested>((event, emit) async {
      emit(AuthLoading());
      final res = await deleteAccountUseCase(NoParams());
      res.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (_) => emit(UnAuthenticated()),
      );
    });
  }
}
