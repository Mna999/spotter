import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';

abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}
