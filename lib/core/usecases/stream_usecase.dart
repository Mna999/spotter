import 'package:dartz/dartz.dart';
import 'package:spotter/core/error/failure.dart';

abstract class StreamUsecase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params);
}
