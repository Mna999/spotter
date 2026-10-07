import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignInParams extends Equatable {
  String email;
  String password;
  SignInParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class SignUpParams extends Equatable {
  String email;
  String password;
  String name;
  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
  @override
  List<Object?> get props => [email, password, name];
}

class ResetParams extends Equatable {
  String email;

  ResetParams({required this.email});
  @override
  List<Object?> get props => [email];
}
